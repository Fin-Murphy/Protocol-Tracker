# ScatterBrainVVD Data Handling Flow

## Overview

ScatterBrainVVD is a habit tracking app that uses **SwiftData** for persistent storage of habits, tasks, and daily items, with **UserDefaults** for lightweight settings and scoring.

---

## Architecture

### Storage Layers

| Layer | Technology | Purpose |
|-------|------------|---------|
| Primary | SwiftData (SQLite) | Persistent storage of habits, tasks, daily items |
| Secondary | UserDefaults | Settings, scoring, lightweight state |

### SwiftData Models (BuilderViews/Datum.swift)

All fields are non-optional with defaults; integer fields are `Int`.

```
listItem (Daily task/habit instance)
├── id: UUID
├── name: String
├── goal: Int (target value)
├── value: Int (current progress)
├── unit: String
├── complete: Bool
├── timestamp: Date
├── whichProtocol: String
├── reward: Int (points)
├── hasStatus: Bool
├── hasCheckbox: Bool
├── isTask: Bool
├── notFloater: Bool
├── statusText: String
├── timeRegion: String (Morning/Noon/Afternoon/Evening, "None" = any time)
└── descriptor: String

listItem(from: habItem, timestamp: Date) — convenience init that spawns a
fresh checklist instance from a habit template (used by populateTasks,
HabitBuilderView.addItem, and generateTestHabitData).

habItem (Template for recurring habits)
├── id: UUID
├── name: String
├── goal: Int
├── unit: String
├── whichProtocol: String
├── repeatValue: Int (interval)
├── descript: String
├── startDate: Date
├── reward: Int
├── hasStatus: Bool
├── hasCheckbox: Bool
├── isSubtask: Bool
├── hasSubtask: Bool
├── order: Int
├── useDow: Bool (day of week)
├── dow: dow (related model holding onSun through onSat Bools)
└── timeRegion: String (Morning/Noon/Afternoon/Evening, "None" = any time)

taskItem (One-off tasks)
├── id: UUID
├── name: String
├── descript: String
├── goal: Int
├── unit: String
├── dueDate: Date
├── reward: Int
├── hasCheckbox: Bool
└── notFloater: Bool

dayScore (Historical daily scores)
├── day: Date
└── score: Int
```

---

## Data Flow

### 1. Habit Creation Flow

```
User Input (HabitBuilderView)
        ↓
Create habItem (SwiftData)
        ↓
modelContext.insert + save
        ↓
Index protocols to UserDefaults (indexProtocols())
```

### 2. Daily Population Flow

```
App Launch → checkDate() in MainListTab
        ↓
Is it a new day? (compare to DailyTaskPopulate)
        ↓
YES: Run populateTasks()
        ↓
For each habItem:
    - Check if habit should appear today
      (interval-based OR day-of-week based)
        ↓
    - Insert a listItem for today (listItem(from:timestamp:))
        ↓
    - Run shuntTodaysTasks() for due taskItems
        ↓
Update DailyTaskPopulate in UserDefaults
```

### 3. Tracking Progress Flow

```
User views MainListTab
        ↓
For each listItem:
    - Checkbox items: tap to toggle complete
    - Unit-based items: use +/- buttons
        ↓
addValue() / subValue() updates listItem.value
        ↓
When value >= goal:
    → completeHabit() called
    → Add reward points to today's dayScore.score
    → Mark listItem.complete = true
```

### 4. Scoring Flow

Each calendar day owns a persistent `dayScore` record holding that day's point total, so
the per-day score survives indefinitely and the date-bar chevrons can read back the score
for any past day.

```
User completes habit (value >= goal)
        ↓
completeHabit() function:
    - listItem.complete = true
    - dayData(for: today).score += listItem.reward (SwiftData)
      (dayScore row is created lazily on the first point of the day)
    - Celebrate binding = today's score
        ↓
Check: Celebrate >= dailyGoal?
        ↓
YES: Trigger celebrationProcedure()
     (haptic feedback)

DateBarView reads its @Query of dayScore rows to display the
chosen day's total; today's record updates the view live.
```

### 5. Notification Flow

```
App appears (onAppear in MainListTab)
        ↓
generateNotifications() called
        ↓
HabitNotificationManager schedules reminders
        ↓
For each remaining hour of the day (stepped by notifFreq):
    - Build a body from today's incomplete listItems whose
      timeRegion matches that hour's region, plus items
      with timeRegion "None" (included in every sendout)
    - Regions: Morning 12am-12pm, Noon 12:01pm-3pm,
      Afternoon 3:01pm-7pm, Evening 7:01pm-11:59pm
    - Skip hours whose body would be empty
```

### 6. Moving Tasks Flow

```
User swipes/taps to move item:
    - scootItem() → move to tomorrow
    - shuntTask() → convert task to today's item
        ↓
Update listItem.timestamp to next day
        ↓
Items marked notFloater persist across days
```

---

## Key Functions (Globals.swift)

Free functions take an explicit `modelContext: ModelContext` parameter.

| Function | Purpose |
|----------|---------|
| `populateTasks()` | Create daily items from habit templates (in MainListTab) |
| `shuntTodaysTasks()` | Convert due tasks to today's items |
| `addValue()` / `subValue()` | Increment/decrement item progress |
| `completeHabit()` | Mark habit complete, add reward points |
| `dayData(for:)` | Get-or-create a day's dayScore record (inserts on create) |
| `scoreFor(date:)` | Read-only lookup of a day's stored score |
| `scootItem()` | Move incomplete item to tomorrow |
| `shuntTask()` | Convert task to today's item |
| `deleteEntity` / `deleteEntityTask` | Delete items/tasks by UUID |
| `saveContext()` | SwiftData save wrapper |
| `celebrationProcedure()` | Trigger when daily goal reached |
| `generateNotifications()` | Schedule smart reminders |
| `indexProtocols()` | Sync protocols to UserDefaults |

---

## UserDefaults Keys

| Key | Type | Purpose |
|-----|------|---------|
| `dailyGoal` | Int | Target points per day |
| `notifFreq` | Int | Notification frequency in hours |
| `seenWelcome` | Bool | First launch flag |
| `DailyTaskPopulate?` | Date | Last population date |
| `protocol` | [HabitProtocol] | Array of Codable protocols |

---

## View Hierarchy

```
ScatterBrainVVDApp (Entry Point)
        ↓
ContentView (Router)
        ↓
TabView (5 tabs via TabBar)
├── CalendarView
├── SettingsView
├── MainListTab (Hub - daily tasks)
├── ProtocolListView
└── GoalSetView

Sub-views:
├── HabitBuilderView
├── TaskBuilderView
├── DateBarView
└── ListLabelView
```

---

## Persistence

**ScatterBrainVVDApp.swift** attaches the SwiftData container at the root:

```swift
ContentView()
    .modelContainer(for: [habItem.self, listItem.self, taskItem.self, dayScore.self])
```

- Views read via `@Query` and mutate via `@Environment(\.modelContext)`
- SQLite backing store (SwiftData default.store)
- Previews use `.modelContainer(..., inMemory: true)`
