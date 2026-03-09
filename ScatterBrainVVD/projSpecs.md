# ScatterBrainVVD Data Handling Flow

## Overview

ScatterBrainVVD is a habit tracking app that uses **Core Data** for persistent storage of habits, tasks, and daily items, with **UserDefaults** for lightweight settings and scoring.

---

## Architecture

### Storage Layers

| Layer | Technology | Purpose |
|-------|------------|---------|
| Primary | Core Data (SQLite) | Persistent storage of habits, tasks, daily items |
| Secondary | UserDefaults | Settings, scoring, lightweight state |

### Core Data Entities

```
Item (Daily task/habit instance)
├── id: UUID
├── name: String
├── goal: Int16 (target value)
├── value: Int16 (current progress)
├── unit: String
├── complete: Boolean
├── timestamp: Date
├── whichProtocol: String
├── reward: Int16 (points)
├── hasStatus: Boolean
├── hasCheckbox: Boolean
├── isTask: Boolean
├── notFloater: Boolean
├── status: Int16
└── descriptor: String

HabitItem (Template for recurring habits)
├── id: UUID
├── name: String
├── goal: Int16
├── unit: String
├── whichProtocol: String
├── repeatValue: Int16 (interval)
├── descript: String
├── startDate: Date
├── reward: Int16
├── hasStatus: Boolean
├── hasCheckbox: Boolean
├── isSubtask: Boolean
├── hasSubtask: Boolean
├── superTask: UUID
├── order: Int32
├── useDow: Boolean (day of week)
├── onSun through onSat: Booleans (day selection)
└── (not persisted in Core Data - recreated daily)

TaskItem (One-off tasks)
├── id: UUID
├── name: String
├── descript: String
├── goal: Int16
├── unit: String
├── dueDate: Date
├── reward: Int16
├── hasCheckbox: Boolean
└── notFloater: Boolean

DayData (Historical daily scores)
├── day: Date
├── score: Int16
└── habits: Date
```

---

## Data Flow

### 1. Habit Creation Flow

```
User Input (HabitBuilderView)
        ↓
Create HabitItem (Core Data)
        ↓
Save to Core Data via saveViewContext()
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
For each HabitItem:
    - Check if habit should appear today
      (interval-based OR day-of-week based)
        ↓
    - Create Item entity for today
        ↓
    - Run shuntTodaysTasks() for due TaskItems
        ↓
Update DailyTaskPopulate in UserDefaults
```

### 3. Tracking Progress Flow

```
User views MainListTab
        ↓
For each Item:
    - Checkbox items: tap to toggle complete
    - Unit-based items: use +/- buttons
        ↓
addValue() / subValue() updates Item.value
        ↓
When value >= goal:
    → completeHabit() called
    → Add reward points to TodayScore
    → Mark Item.complete = true
```

### 4. Scoring Flow

```
User completes habit (value >= goal)
        ↓
completeHabit() function:
    - Item.complete = true
    - TodayScore += Item.reward (UserDefaults)
        ↓
Check: TodayScore >= dailyGoal?
        ↓
YES: Trigger celebrationProcedure()
     (haptic feedback)
```

### 5. Notification Flow

```
App appears (onAppear in MainListTab)
        ↓
generateNotifications() called
        ↓
HabitNotificationManager schedules reminders
        ↓
For each incomplete Item:
    - Schedule notification at hourly intervals
    - Based on notifFreq setting (UserDefaults)
```

### 6. Moving Tasks Flow

```
User swipes/taps to move item:
    - scootItem() → move to tomorrow
    - shuntTask() → convert task to today's item
        ↓
Update Item.timestamp to next day
        ↓
Items marked notFloater persist across days
```

---

## Key Functions (Globals.swift)

| Function | Purpose |
|----------|---------|
| `populateTasks()` | Create daily items from habit templates |
| `shuntTodaysTasks()` | Convert due tasks to today's items |
| `addValue()` / `subValue()` | Increment/decrement item progress |
| `completeHabit()` | Mark habit complete, add reward points |
| `scootItem()` | Move incomplete item to tomorrow |
| `shuntTask()` | Convert task to today's item |
| `deleteEntity*()` | Delete items by UUID |
| `saveViewContext()` | Core Data save wrapper |
| `celebrationProcedure()` | Trigger when daily goal reached |
| `generateNotifications()` | Schedule smart reminders |
| `indexProtocols()` | Sync protocols to UserDefaults |

---

## UserDefaults Keys

| Key | Type | Purpose |
|-----|------|---------|
| `TodayScore` | Int | Current day's accumulated points |
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

**Persistence.swift** provides the Core Data container:

```swift
PersistenceController.shared.container.viewContext
```

- Auto-merges changes from parent context
- SQLite backing store
- Preview mode available for development
