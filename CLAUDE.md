# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Protocol Tracker (Xcode project name: **ScatterBrainVVD**) is a native SwiftUI iOS app that auto-populates a daily checklist from user-defined recurring habits ("protocols") and one-off tasks. The repo folder is named Protocol-Tracker but all targets, schemes, and source directories use the ScatterBrainVVD name.

The app is no longer under active feature development (superseded by the author's Reverb project), but the codebase remains the reference implementation.

A detailed data-flow document lives at `ScatterBrainVVD/projSpecs.md` — read it for the SwiftData model schemas, UserDefaults keys, and the six main data flows (habit creation, daily population, progress tracking, scoring, notifications, task moving). Its "View Hierarchy" section is stale; trust the Views section below instead.

## Build & Test Commands

There is no package manager, linter, or CI — this is a plain Xcode project with no external dependencies (a leftover Supabase client stub remains commented out in `Globals.swift`).

```sh
# Build for iOS Simulator
xcodebuild -project ScatterBrainVVD.xcodeproj -scheme ScatterBrainVVD \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run tests (unit + UI; note: test targets are currently empty templates)
xcodebuild -project ScatterBrainVVD.xcodeproj -scheme ScatterBrainVVD \
  -destination 'platform=iOS Simulator,name=iPhone 17' test

# Run a single test
xcodebuild -project ScatterBrainVVD.xcodeproj -scheme ScatterBrainVVD \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:ScatterBrainVVDTests/ScatterBrainVVDTests/example test
```

The app target's deployment target is **iOS 26** (the test targets still say 18.5), so the simulator must run an iOS 26 runtime. `habItem` is annotated `@available(iOS 26, *)`. The only scheme is `ScatterBrainVVD`; marketing version is 7.

## Architecture

### Storage: two layers, five model types

- **SwiftData** (models in `BuilderViews/Datum.swift`, container attached in `ScatterBrainVVDApp.swift`) holds the persistent models. Understanding their relationship is the key to the whole app:
  - `habItem` — the *template* for a recurring habit (repeat interval or day-of-week flags via the related `dow` model, start date, reward points, `colorName`, optional `subhabits: [String]`). When a habit uses subhabits, `goal == subhabits.count` and `unit == "subhabits"` (enforced in `HabitBuilderView` on save).
  - `taskItem` — a one-off task with a due date, waiting to come due.
  - `listItem` — a concrete *instance* on a specific day's checklist. Habits spawn listItems daily (via the `listItem(from:timestamp:)` convenience init, which also copies `colorName`/`subhabits` and zeroes `subhabitChecked`); taskItems are converted ("shunted") into listItems when their due date arrives and the taskItem is deleted.
  - `eventItem` — a reminder-only recurrence (same interval/dow fields as a habit, plus `fireTime`/`useExactTime`/`timeRegion`). It **never becomes a listItem** and has no score or completion; its only output is notifications.
  - `dayScore` — one record per calendar day holding that day's accumulated points (`dayData(for:)` get-or-creates, `scoreFor(date:)` is read-only).
  - `habSubItem` is a declared-but-unused subclass of `habItem` (not in the model container, referenced nowhere). Leave it alone unless the task is about it.
- **UserDefaults** holds notification settings (`notifFreq`, `miniNotifFreq`, `hourlyNotifsDisabled`, `miniNotifsDisabled`), sleep schedule (`wakeupTime` — read by the wake-up nudge notification pass; `bedtime` — stored but not yet consumed by any logic), tab visibility (`hideTab*`), the last-population date (`DailyTaskPopulate?`), the celebration latch (`lastCelebrationDay`), and the JSON-encoded `[HabitProtocol]` array under key `protocol` (via the `setEncodable`/`getDecodable` extension in `Globals.swift`). There is **no `dailyGoal` key anymore** — see Scoring below.

There are parallel Codable structs (`Habit`, `Task`, `HabitProtocol` in `Globals.swift`) that mirror the SwiftData models — `Habit`/`Task` are used by the bundled protocol library and builders, while `HabitProtocol` is what gets persisted to UserDefaults. Field changes generally must be kept in sync across the struct, the SwiftData model, and `projSpecs.md`.

### The daily population cycle

`MainListTab.swift` is the hub. On appear, `checkDate()` compares today against `DailyTaskPopulate?`; on a new day it runs `populateTasks()` (creates a `listItem` for each `habItem` due today, by interval math or day-of-week flags), `shuntTodaysTasks()` (converts due `taskItem`s), and `generateNotifications()`. The list's `@Query` is built in `init` with a `#Predicate` that fetches only the selected day's items plus floaters — don't fetch everything and filter in the `ForEach`. Incomplete items can be moved to tomorrow via `scootItem()`, which clones the item to the next day and prefixes the old one with `"> "` (bullet-journal migration symbology).

### Scoring and the daily goal

The day's goal is **derived, not configured**: `goalTotal(for:)`/`goalFor(date:)` sum the `reward` of every listItem on that day, excluding `"> "`-prefixed (scooted) items so migrating something can't make the day unwinnable. `addValue`/`completeHabit` add the reward to today's `dayScore` and call `checkDayCompletion()`, which fires `celebrationProcedure()` at most once per day (latched by `lastCelebrationDay`) and only when the goal is > 0.

### Notifications (Globals.swift `generateNotifications`)

Rebuilt from scratch (all pending requests removed) on launch, foregrounding, every progress mutation, day rollover, and settings changes (including the Wakeup picker). Four passes of non-repeating requests, budgeted against iOS's 64-pending cap. The nudge pass targets the next three days; the other three cover the rest of today:
1. **Wake-up nudge pass** — two requests on each of the next three calendar days, at `wakeupTime` + 10 min and + 60 min (`"wake-nudge <dayOffset> <10|60>"`; unset key = 7:00 AM). Nothing is scheduled for today, so opening the app clears that day's nudges. Always reserves 6 slots and runs even if both digest toggles are off.
2. **Event pass** — due `eventItem`s with `useExactTime` get a dedicated request at `fireTime`'s hour:minute (`"event-reminder <uuid>"`). Runs even if both digest toggles are off. Capped at 58 (64 minus the nudges).
3. **Hourly digest** — every `notifFreq` hours, a list of incomplete items (and region-mode events) whose `timeRegion` matches that hour (`timeRegion(forHour:)`); `"None"` items appear in every sendout. Skipped if `hourlyNotifsDisabled`. Limited to the slots left after nudges and events.
4. **Mini pass** — every `miniNotifFreq` minutes, a single "top of list" incomplete item for the current region. Skipped if `miniNotifsDisabled`. Budget is `min(40, 64 − 6 − hourly − events)`; if the configured interval would exhaust it before midnight, the interval is widened for that rebuild only (never saved) so the reminders spread evenly to midnight.

### Shared logic lives in Globals.swift

By deliberate convention, nearly all business logic is in free functions in `Globals.swift` rather than in views: progress mutation (`addValue`/`subValue`/`completeHabit`), scoring (`dayData`/`scoreFor`/`goalFor`/`checkDayCompletion`), entity deletion (`deleteEntity`/`deleteEntityTask`/`deleteEntityEvent` by UUID), task shunting, notification scheduling, `habitColor(_:)` (maps `colorName` → light/dark `Color` pair; options in `habitColorOptions`), and `indexProtocols()` (reconciles the UserDefaults protocol array against the habits actually in SwiftData). Views call these and pass `modelContext` explicitly.

### Views

- `ContentView` switches on a `Tabs` enum (`Models/TabBar.swift`) rather than using a `TabView`. **The enum case names are historical and do not match what they show:**
  - `.Calendar` → `SettingsView` (gear icon)
  - `.Protocols` → `HabitBuilderView` ("Habits")
  - `.HUB` → `MainListTab` (center hub)
  - `.Goals` → `TaskBuilderView` ("Log")
  - `.Settings` → `GraphTabView` ("Graphs": weekly per-habit completion, pageable by week)
  - `.ProtocolList` → `ProtocolListView`, `.Events` → `EventBuilderView`, `.Test` → `TestView` (all hidden by default)
  - Tab visibility is driven by `@AppStorage("hideTab…")` flags toggled in `SettingsView` (max 6 active tabs).
- `CalendarView` and `GoalSetView` still exist in `BuilderViews/` but are no longer routed (calendar was replaced by the date-picker popover in `DateBarView`; the daily goal is now derived).
- `BuilderViews/` contains the tab screens plus `HabitBuilderView`/`TaskBuilderView`/`EventBuilderView` (creation/editing forms).
- `Models/` despite its name contains reusable view components (`DateBarView`, `ListLabelView`, `HabitDetailView`, `SymbolButton`, `ProtocolLibraryModal`), not data models.
- `AppProtocolLibrary.swift` defines the bundled protocol library (e.g. the Huberman Daily protocol) users can adopt.

### Conventions and quirks

- Mutating functions call `saveContext(modelContext:)` themselves; many also re-run `generateNotifications()`. Follow that pattern when adding mutations.
- Scoring only applies when the item's timestamp is today (`Calendar.current.isDate(..., toGranularity: .day)`); past/future items toggle completion without touching `dayScore`.
- `notFloater` semantics: items marked `notFloater == true` stick to their day; "floater" items persist until completed (and `populateTasks` re-stamps them to today each rollover).
- Subhabit items: each subhabit checkbox calls `addValue(1)`/`subValue(1)`; `completeHabit` checks them all.
- `ProTrack To-Do.md` and `ProTrack.md` at the repo root are Obsidian kanban boards with the backlog and known bugs (e.g. "move to tomorrow uses the item's timestamp, not the current date" — still true in `scootItem`). `ProTrack.md` is the newer, trimmed board.
