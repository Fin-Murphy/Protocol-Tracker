# Protocol Tracker

> One of the greatest causes of unnecessary mental strain every day is decision fatigue. In a primarily knowledge-work society like ours, few can afford to waste precious cognitive power on the chore of figuring out what they have to do every day, which is why I designed and built Protocol Tracker.
>
> Protocol Tracker allows the user to completely automate the timing and tracking of both repeating habits and unique tasks, and combines them in a sleek interface that eliminates the need for sprawling task spreadsheets or manually writing down your habits and to-dos every day by hand. It consolidates all initiatives into an easy-to-read list every day that you can follow and check off as you complete them.
>
> This application attempts to combine bullet journalling and Emacs Org Mode functionalities for maximum ease of use when deciding what to do each day. Forget the hassle of manual to-do lists, and keeping up with calendars — Protocol Tracker allows you to "set it and forget it".

---

## Overview

Protocol Tracker (internal codename: **ScatterBrainVVD**) is a native iOS application that unifies recurring habits and one-off tasks into a single, automatically populated daily checklist. Rather than asking the user to re-author their to-do list every morning, Protocol Tracker derives the day's agenda from a library of user-defined "protocols" — bundles of habits with their own repeat cadences — plus any non-recurring tasks that come due that day.

The user defines what they want to do *once*; the app handles *when* it shows up, *how* it's tracked, and *what* counts as complete from then on.

## The Problem Being Solved

Modern knowledge workers fight three overlapping problems every day:

1. **Decision fatigue** — re-deciding the same routines every morning burns cognitive budget that should go toward actual work.
2. **Tool sprawl** — to-dos live in Google Calendar, Canvas, Gmail, Notion, Obsidian, Slack, and a dozen other inboxes. Reconciling them is a chore in itself.
3. **Bookkeeping overhead** — bullet journalling and Org Mode both work, but they require manual upkeep that scales poorly.

Protocol Tracker's design intent is to absorb all of that. The current iOS app solves problems (1) and (3) for self-managed routines, and the longer-term roadmap (see *Ultimate Goal* below) extends it to (2) by pulling in tasks from external services.

## Ultimate Goal

The long-term vision is a **universal task unifier**: Protocol Tracker should pull in to-dos from disparate applications — Google Calendar, Canvas, Gmail, Notion, Obsidian, Slack, and so on — and merge them with the user's habits into one unified daily list. This way the user doesn't need to bobble between applications, maintain multiple tabs, or constantly context-switch, significantly reducing scheduling overhead and dramatically increasing productivity.

The current app is the foundation for that vision: the daily-list engine, habit/task model, and protocol grouping are already in place. External integrations will plug into the same daily population pipeline.

## How It Works

### Concepts

- **Habit** — a recurring behaviour the user wants to perform on some cadence. Habits can repeat every N days *or* on specific days of the week (Mon/Wed/Fri, weekends only, etc.). Each habit has a goal, unit, and optional reward points.
- **Task** — a one-off to-do with a due date. Tasks "shunt" into the daily list automatically on the day they're due.
- **Protocol** — a named grouping of habits (e.g. *Huberman Daily*, *Morning Routine*, *Pre-Workout*). Protocols make it easy to enable/disable a whole bundle of habits together and to browse curated templates.
- **Item** — the concrete instance of a habit or task that appears on a given day. Items are what the user actually checks off.

### Daily Flow

1. On app launch, `MainListTab` runs `checkDate()` and compares against the last-populated date stored in `UserDefaults`.
2. If it's a new day, `populateTasks()` walks every `HabitItem` and decides whether the habit applies today, based on either an interval (`repeatValue`) or selected weekdays (`useDow` + `onSun`…`onSat`).
3. Each applicable habit becomes a fresh `Item` for the day. Concurrently, `shuntTodaysTasks()` converts any `TaskItem` whose due date is today into an Item on the same list.
4. Incomplete items marked `notFloater` persist across days so unfinished work doesn't disappear; the rest reset cleanly each morning.
5. The user works the list. Checkbox habits toggle complete; unit-based habits (e.g. "10 minutes of sunlight") increment via `+1` / `+5` / `+10` buttons until `value >= goal`.
6. Completion adds the habit's `reward` to `TodayScore`. Crossing the user-set `dailyGoal` triggers a celebration (haptics + future hooks).
7. `generateNotifications()` schedules hourly reminders for the remaining incomplete items at a user-configurable frequency, refreshing on every state change.

### Bundled Protocol Library

The app ships with an `AppDefinedProtocolLibrary` of curated routines — currently the *Huberman Daily* protocol (morning sunlight, delayed caffeine, hydration, exercise, evening light exposure, sleep environment, etc.). Users can adopt these as-is or use them as a starting template.

## Tech Stack

| Layer | Technology |
|---|---|
| Platform | iOS (native) |
| Language | Swift |
| UI Framework | SwiftUI |
| Persistence (primary) | Core Data (SQLite-backed `NSPersistentContainer`) |
| Persistence (lightweight) | `UserDefaults` for score, daily goal, notification frequency, last-populate date, and the encoded protocol index |
| Notifications | `UserNotifications` (`UNCalendarNotificationTrigger` for repeating daily reminders) |
| Haptics | `CoreHaptics` (`CHHapticEngine`) for celebration feedback on hitting the daily goal |
| Build System | Xcode project (`ScatterBrainVVD.xcodeproj`) |
| Testing | XCTest (`ScatterBrainVVDTests`, `ScatterBrainVVDUITests`) |

> A `Supabase.swift` stub is present and the dependency is referenced in the protocol-import code, suggesting cloud sync for shared/community protocols is a planned future feature. It is currently inert.

## Project Structure

```
ScatterBrainVVD/
├── ScatterBrainVVDApp.swift     # @main entry point, injects Core Data context
├── ContentView.swift            # Top-level router; switches between tabs
├── Persistence.swift            # PersistenceController + Core Data container
├── Globals.swift                # Domain logic: scheduling, scoring, notifications, haptics
├── AppProtocolLibrary.swift     # Built-in protocol templates (e.g. Huberman Daily)
├── Supabase.swift               # Stub for future cloud sync
├── ScatterBrainVVD.xcdatamodeld # Core Data schema
├── BuilderViews/
│   ├── MainListTab.swift        # The daily hub — the central screen
│   ├── HabitBuilderView.swift   # Create/edit recurring habits
│   ├── TaskBuilderView.swift    # Create/edit one-off tasks
│   ├── ProtocolListView.swift   # Browse and manage protocols
│   ├── CalendarView.swift       # Calendar / history surface
│   ├── GoalSetView.swift        # Set the daily score goal
│   └── SettingsView.swift       # Notification frequency, etc.
└── Models/
    ├── TabBar.swift             # 5-tab navigation
    ├── DateBarView.swift        # Date header
    ├── HabitDetailView.swift
    ├── ListLabelView.swift
    └── SymbolButton.swift       # Reusable iconographic button
```

## Core Data Model

| Entity | Role |
|---|---|
| `Item` | A concrete habit/task instance for a specific day. What the user actually checks off. Carries `value`, `goal`, `complete`, `timestamp`, `reward`, `hasCheckbox`, `notFloater`, `isTask`, `status`. |
| `HabitItem` | The recurring-habit *template*. Holds cadence (`repeatValue`, `useDow` + per-weekday booleans), goal/unit, ordering, protocol membership, and optional subtask hierarchy (`superTask`). |
| `TaskItem` | The one-off-task template, with a `dueDate`. Becomes an `Item` on its due day via `shuntTask`. |
| `DayData` | Historical record of daily score by date. |

Lightweight state (`TodayScore`, `dailyGoal`, `notifFreq`, `seenWelcome`, `DailyTaskPopulate`, and the encoded `protocol` index) lives in `UserDefaults`.

## UI

Five-tab interface (`TabBar.swift`):

- **HUB** — the daily list (`MainListTab`). The default screen.
- **Protocols** — browse and edit habits/protocols (`HabitBuilderView`).
- **Goals** — author one-off tasks (`TaskBuilderView`).
- **Settings** — daily-goal setting (`GoalSetView`).
- **Calendar** — currently routed to `SettingsView` for general settings; calendar/history surface is in progress.

The interface intentionally leans minimal — single-column list with checkboxes, bullets, and lightweight `+1 / +5 / +10` buttons — to keep the daily-driver loop frictionless.

## Build & Run

1. Open `ScatterBrainVVD.xcodeproj` in Xcode 15 or later.
2. Select an iOS Simulator or a connected device.
3. Build and run (`⌘R`).

No external package management is required for the current shipping feature set; the app uses only system frameworks (SwiftUI, Core Data, UserNotifications, CoreHaptics).

## Roadmap

- **External task ingestion** — Google Calendar, Canvas, Gmail, Notion, Obsidian, Slack, etc., feeding the same daily list.
- **Cloud sync / shared protocols** — Supabase-backed account so users can publish and adopt community-authored protocols. (Hook points already stubbed in `Supabase.swift` and the protocol-library code.)
- **Calendar / history view** — full historical browsing of past days' scores and completion patterns via the `DayData` entity.
- **Richer subtask support** — the `superTask` / `hasSubtask` / `isSubtask` fields exist on `HabitItem` but aren't fully surfaced in the UI yet.
