# Gotchas

Known bugs, traps and stale documents. Everything under "Behaviour" was **read from code, not run**: nobody built or ran the app while writing this page. Treat each as a strong lead and confirm it in the simulator before relying on it. Remove an entry when it is fixed.

## Behaviour

### Rollover needs the Today screen to appear

`checkDate()` is called only from `MainListTab`'s `.onAppear` (`MainListTab.swift:633`). Returning to the foreground rebuilds notifications (`ContentView.swift:115`) but does not call it. If the app is left on Today overnight and brought back the next morning, the new day is not populated until the user switches tabs and back, or relaunches.

### A habit interval of 0 divides by zero

The habit form's Interval field is a free number field (`ScheduleSection`, `DaybookComponents.swift:421`) and its value is saved unchecked (`HabitBuilderView.swift:491`, `:588`). The due test computes `daysBetween(…) % repeatValue` at `HabitBuilderView.swift:617` and `MainListTab.swift:718`; with 0 that traps. A habit saved with interval 0 would crash on save when its start date is today or earlier, and again at every rollover. Events are safe: `EventBuilderView` clamps to 1 (`:290`, `:323`) and the notification pass uses `max(repeatValue, 1)` (`Globals.swift:108`).

### A scooted task returns as a `"> "` task

`scootItem` renames the original list item to `"> name"` and leaves it unfinished with `isTask` unchanged (`Globals.swift:445`). At the next rollover `populateTasks` deshunts every unfinished, non-floater task row from an earlier day (`MainListTab.swift:698`), so the marker becomes a new `taskItem` named `"> name"`, due the following day, alongside the real copy.

### Scooted markers can still be completed

The trailing "Complete" swipe and the "Complete" accessibility action are offered on every row, including scooted markers (`MainListTab.swift:432`, `:449`). Completing one adds its reward to the score, but `goalTotal` leaves it out of the goal, so the score can pass the goal.

### Scoot counts from the item's day

The copy is stamped `item.timestamp + 1 day` (`Globals.swift:434`), not tomorrow. Scooting an item while viewing a past day puts the copy on the day after that past day. Listed on the kanban boards as a known bug.

### An unfinished task skips a day

`deshuntTask` gives the returned task `dueDate` = tomorrow (`MainListTab.swift:752`), and it runs before `shuntTodaysTasks` in the same rollover. A task left unfinished on Monday is absent from Tuesday's list and due on Wednesday.

### Tasks with a past due date are never picked up

`shuntTodaysTasks` fetches only tasks due today (`Globals.swift:538`). If the app is not opened on a task's due date, the task stays in the Tasks tab until the user taps "Move to today's list".

### Deleting a completed item keeps its points

`deleteEntity` (`Globals.swift:455`) removes the list item without touching `dayScore`. The goal falls by the item's reward and the score does not.

### Progress can go below zero

For today's items `subValue` checks only `item.value > 0` before subtracting the whole amount (`Globals.swift:761`), so −5 at a value of 2 gives −3. For other days there is no check at all (`:777`).

### Editing a task cannot change "Carry over until done"

The edit form loads `notFloater` (`TaskBuilderView.swift:161`) but `updateTask` (`:267`) never writes it back.

### Weekday schedules depend on an English device locale

The weekday is produced by a `DateFormatter` with format `"EEEE"` and no fixed locale, then compared with `"Monday"` … `"Sunday"` (`MainListTab.swift:691`, `HabitBuilderView.swift:541`, `Globals.swift:96`). On a device set to another language no weekday habit or event would match.

### Name matching

A list item has no reference to its habit; features find the habit by `name`.

- `displayHabitDescription` (`Globals.swift:556`) returns the description of the first habit with the same name. A scooted marker (`"> name"`) matches nothing and shows "No description". Two habits with one name share the first one's description.
- `GraphTabView.weekPoints` (`:172`) matches by name. Renaming a habit detaches its history from the graph. A task that shares a habit's name counts as that habit.

### Paging to another day

The list query includes all floaters on every day (`MainListTab.swift:343`); the header's goal query does not (`DateBarView.swift:73`). On a day other than today the header's goal can exclude floaters the list shows.

### Adopted library habits miss today

`ProtocolLibraryModal.incorporateHabit` (`:157`) creates the habit only. Unlike `HabitBuilderView.addItem`, it does not create today's list item.

### Deleting a habit leaves its list items

`HabitBuilderView.swift:460` deletes the `habItem` only. Today's row and all history remain.

### Scooted markers appear in notifications

`generateNotifications` treats every unfinished item stamped today as pending (`Globals.swift:169`-`:175`), including `"> "` markers. They are listed in digests and can be chosen as the mini check-in's top item.

### Failures crash

`saveContext` (`Globals.swift:599`), `shuntTodaysTasks` (`:547`) and `generateNotifications` (`:246`) call `fatalError` when a save or fetch throws.

### Every progress tap refetches everything

`addValue`, `completeHabit` and `subValue` each end with `generateNotifications`, which fetches all list items and all events and rebuilds every pending request.

## Traps when editing

- **String-typed values.** `timeRegion`, `colorName`, `whichProtocol`, the unit `"subhabits"` and the `"> "` prefix are all plain strings compared with `==` or `hasPrefix`. A typo fails silently.
- **`notFloater` is a negative.** `false` means the item carries over. The task form shows it inverted as "Carry over until done".
- **Tab enum names.** `.Settings` is Graphs and `.Calendar` is Settings; see [overview](overview.md#misleading-names). The section banners in `ContentView.swift` ("BOOK TAB", "MONEY TAB") are older still.
- **`.onAppear` runs on every tab switch**, because `ContentView` rebuilds the screen each time.
- **iOS 26.** `habItem` is `@available(iOS 26, *)` and the app target requires iOS 26; the test targets still say 18.5.
- **Committed Xcode user state.** `UserInterfaceState.xcuserstate` and other `xcuserdata` files are tracked. Leave them out of your commits.
- **Dead code that looks live.** `CalendarView`, `GoalSetView`, `HabitDetailView`, `ListLabelView`, `habSubItem`, the `Task` struct. See [file-map](file-map.md).

## Documents that are out of date

| Document | Says | Code says |
| --- | --- | --- |
| `CLAUDE.md` | Marketing version is 7 | `MARKETING_VERSION = 9` in `project.pbxproj` |
| `CLAUDE.md` | `.Goals` is labelled "Log" | The bar label is "Tasks" (`TabBar.swift:53`) |
| `CLAUDE.md` | `.Test` is hidden by default | It has no bar entry and no toggle; nothing can select it |
| `projSpecs.md`, Scoring Flow | Completion compares against `dailyGoal` | There is no stored goal; see [scoring](scoring.md) |
| `projSpecs.md`, Moving Tasks Flow | Scoot updates the item's timestamp; `notFloater` items persist across days | Scoot inserts a copy and renames the original; items with `notFloater == false` are the ones that persist |
| `projSpecs.md`, View Hierarchy | An older screen tree | `CLAUDE.md` already flags this section as stale; use [views](views.md) |
| `ProTrack.md` | "Move to tomorrow" timestamp bug is in the Archive list | Still present at `Globals.swift:434` |
