# The daily cycle

How list items come to exist on a day, and how they move. Everything here is in `BuilderViews/MainListTab.swift` and `Globals.swift`.

## Rollover: `checkDate()` (`MainListTab.swift:644`)

Called from `MainListTab`'s `.onAppear` (`:633`), and from nowhere else.

```
checkDate()
  saved = UserDefaults "DailyTaskPopulate?"
  if saved is missing:            (first launch)
      store now; populateTasks()
  else if today is a later calendar day than saved:
      populateTasks()
      generateNotifications()
      store now; Celebrate = 0; SelectedDate = today
  else: nothing
```

The trigger is the Today screen appearing. Foregrounding the app re-runs notifications (`ContentView.swift:115`) but not `checkDate()`; see [gotchas](gotchas.md#rollover-needs-the-today-screen-to-appear).

## `populateTasks()` (`MainListTab.swift:687`)

Runs once per calendar day, in this order:

1. **Sweep old task rows and floaters** (`:696`-`:703`). For every list item that is a task or a floater:
   - an unfinished, non-floater task from another day is **deshunted** (`deshuntTask`, `:749`): a new `taskItem` is made with `dueDate` = tomorrow and the list item is deleted;
   - a floater has its `timestamp` set to now.
2. **Shunt today's tasks** (`shuntTodaysTasks`, `Globals.swift:534`): every `taskItem` whose `dueDate` falls today becomes a list item (`shuntTask`, `Globals.swift:509`) and the task is deleted.
3. **Spawn habits** (`:711`-`:739`). For each `habItem`:
   - interval mode (`useDow == false`): due when `daysBetween(startDate, today) >= 0` and that number `% repeatValue == 0`;
   - weekday mode: due when today's weekday flag is set on `dow`. The weekday comes from a `DateFormatter` with format `"EEEE"` compared against English names (`"Monday"` …).
   - a due habit gets `listItem(from: habit, timestamp: now)`.
4. `saveContext`.

Habits are fetched by the view's `@Query` sorted on `order` (`:559`), and new items are stamped with the current time in that order, so the Today list (sorted by `timestamp`) follows the Habits order.

## Other ways a list item is created

| Where | When |
| --- | --- |
| `HabitBuilderView.addItem()` (`:612`-`:638`) | A new habit that is due today gets today's list item at once, using the same due test as populate. |
| `TaskBuilderView.addTask()` (`:315`) | Calls `shuntTodaysTasks`, so a task created with today's date goes straight to the list. |
| Tasks detail, "Move to today's list" (`TaskBuilderView.swift:147`) | `shuntTask` on demand, whatever the due date. |
| `scootItem` (`Globals.swift:420`) | The clone on the next day. |
| `generateTestHabitData` (`Globals.swift:889`) | 14 days of random history; not called by any view. |

Editing a habit does not change list items that already exist.

## What the Today list shows

`dayListView` builds its `@Query` in `init` (`MainListTab.swift:343`):

```
(timestamp within the selected day) OR (notFloater == false)
sorted by timestamp
```

So floaters appear on every day the user pages to. The rows are split into "To do" and "Done" groups in `body` (`:490`). The header (`DateBarView`) runs its own query for the selected day only.

Keep the predicate in the query. `CLAUDE.md` asks that the list never fetch every item and filter in `ForEach`.

## Floaters

A floater is a list item with `notFloater == false`. Only tasks can start as floaters (the task form's "floating" toggle); habit items are always created with `notFloater: true`.

- Each time the Today list appears, `testTasksForSillyness()` (`:675`) sets every floater's `timestamp` to now.
- `populateTasks` does the same at rollover.
- Completing a floater sets `notFloater = true` (`Globals.swift:685`, `:731`), pinning it to the day it was finished.
- Floaters cannot be scooted (the control is shown only when `notFloater == true`).

## Scoot: move to tomorrow (`scootItem`, `Globals.swift:420`)

1. Insert a copy with a new `id`, `value = 0`, `complete = false`, `notFloater = true`, and `timestamp` = the **item's own** timestamp plus one day.
2. Rename the original to `"> " + name`. It stays on its day, unfinished, as a bullet-journal "migrated" marker.

Offered only when `notFloater == true && complete == false`: the swipe action (`MainListTab.swift:457`), the detail button (`:303`) and an accessibility action (`:434`).

Everything that reads names must cope with the prefix: `displayName` (`MainListTab.swift:12`) and `GraphTabView.baseName` (`:183`) strip it; `goalTotal` skips prefixed items.

## Tasks, start to finish

```
taskItem (Tasks tab)
   |  due today at rollover, created today, or "Move to today's list"
   v
listItem (isTask = true)
   |-- completed            -> stays on that day
   |-- unfinished, not a floater, at the next rollover
   |        -> deshunt: back to taskItem, due the day after that rollover
   '-- unfinished floater   -> re-stamped to today, every day
```

`shuntTodaysTasks` only picks up tasks due **today**. A task whose due date has passed without a rollover on that day stays in the Tasks tab until the user moves it by hand.

## `daysBetween` (`Globals.swift:572`)

Whole days from `start` to `end` using `Calendar.current`. Callers pass start-of-day dates on both sides. Negative when the habit starts in the future, which is why the due test checks `>= 0`.
