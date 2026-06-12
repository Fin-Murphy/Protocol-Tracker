# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Protocol Tracker (Xcode project name: **ScatterBrainVVD**) is a native SwiftUI iOS app that auto-populates a daily checklist from user-defined recurring habits ("protocols") and one-off tasks. The repo folder is named Protocol-Tracker but all targets, schemes, and source directories use the ScatterBrainVVD name.

The app is no longer under active feature development (superseded by the author's Reverb project), but the codebase remains the reference implementation.

A detailed data-flow document lives at `ScatterBrainVVD/projSpecs.md` — read it for the Core Data entity schemas, UserDefaults keys, and the six main data flows (habit creation, daily population, progress tracking, scoring, notifications, task moving).

## Build & Test Commands

There is no package manager, linter, or CI — this is a plain Xcode project with no external dependencies (Supabase integration exists but is fully commented out in `Supabase.swift` and `Globals.swift`).

```sh
# Build for iOS Simulator
xcodebuild -project ScatterBrainVVD.xcodeproj -scheme ScatterBrainVVD \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests (unit + UI; note: test targets are currently empty templates)
xcodebuild -project ScatterBrainVVD.xcodeproj -scheme ScatterBrainVVD \
  -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test
xcodebuild -project ScatterBrainVVD.xcodeproj -scheme ScatterBrainVVD \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:ScatterBrainVVDTests/ScatterBrainVVDTests/example test
```

Deployment target is iOS 18.5; the only scheme is `ScatterBrainVVD`.

## Architecture

### Storage: two layers, three entity types

- **Core Data** (`Persistence.swift`, model in `ScatterBrainVVD.xcdatamodeld`) holds the three entities. Understanding their relationship is the key to the whole app:
  - `HabitItem` — the *template* for a recurring habit (repeat interval or day-of-week flags, start date, reward points).
  - `TaskItem` — a one-off task with a due date, waiting to come due.
  - `Item` — a concrete *instance* on a specific day's checklist. Habits spawn Items daily; TaskItems are converted ("shunted") into Items when their due date arrives and the TaskItem is deleted.
- **UserDefaults** holds scoring (`TodayScore`, `dailyGoal`), settings (`notifFreq`), the last-population date (`DailyTaskPopulate?`), and the JSON-encoded `[HabitProtocol]` array under key `protocol` (via the `setEncodable`/`getDecodable` extension in `Globals.swift`).

There are parallel Codable structs (`Habit`, `Task`, `HabitProtocol` in `Globals.swift`) that mirror the Core Data entities — `Habit`/`Task` are used by the bundled protocol library and builders, while `HabitProtocol` is what gets persisted to UserDefaults. Field changes generally must be kept in sync across the struct, the Core Data entity, and `projSpecs.md`.

### The daily population cycle

`MainListTab.swift` is the hub. On appear, `checkDate()` compares today against `DailyTaskPopulate?`; on a new day it runs `populateTasks()` (creates an `Item` for each `HabitItem` due today, by interval math or day-of-week flags) and `shuntTodaysTasks()` (converts due `TaskItem`s). Incomplete items can be moved to tomorrow via `scootItem()`, which clones the Item to the next day and prefixes the old one with `"> "` (bullet-journal migration symbology).

### Shared logic lives in Globals.swift

By deliberate convention, nearly all business logic is in free functions in `Globals.swift` rather than in views: progress mutation (`addValue`/`subValue`/`completeHabit` — these also update `TodayScore` and trigger the celebration check), entity deletion (`deleteEntity*` by UUID), task shunting, notification scheduling (`generateNotifications` rebuilds all pending notifications from scratch on every mutation), and `indexProtocols()` (reconciles the UserDefaults protocol array against the habits actually in Core Data). Views call these and pass `viewContext` explicitly.

### Views

- `ContentView` routes to a 5-tab `TabView` (`Models/TabBar.swift`): `CalendarView`, `SettingsView`, `MainListTab` (center hub), `ProtocolListView`, `GoalSetView`.
- `BuilderViews/` contains the tab screens plus `HabitBuilderView`/`TaskBuilderView` (creation/editing forms).
- `Models/` despite its name contains reusable view components (`DateBarView`, `ListLabelView`, `HabitDetailView`, `SymbolButton`), not data models.
- `AppProtocolLibrary.swift` defines the bundled protocol library (e.g. the Huberman Daily protocol) users can adopt.

### Conventions and quirks

- Mutating functions call `saveViewContext()` themselves; many also re-run `generateNotifications()`. Follow that pattern when adding mutations.
- Scoring only applies when the item's timestamp is today (`Calendar.current.isDate(..., toGranularity: .day)`); past/future items toggle completion without affecting `TodayScore`.
- `notFloater` semantics: items marked `notFloater == true` stick to their day; "floater" items persist until completed.
- `ProTrack To-Do.md` at the repo root is an Obsidian kanban board with the backlog and known bugs (e.g. "move to tomorrow uses the item's timestamp, not the current date").
