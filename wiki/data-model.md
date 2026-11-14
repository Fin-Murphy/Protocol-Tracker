# Data model

Two stores: **SwiftData** for items and scores, **UserDefaults** for settings, latches and the protocol list.

## SwiftData models (`BuilderViews/Datum.swift`)

The container is declared at `ScatterBrainVVDApp.swift:17` with `habItem`, `listItem`, `taskItem`, `dayScore`, `eventItem`. There is no explicit schema versioning or migration plan; every stored property has a default value.

### How the models relate

```
habItem  --populate (daily)-->  listItem  <--shunt--  taskItem
(template)                     (one row,             (pending
                                one day)  --deshunt-->  one-off)

eventItem  -->  notifications only
dayScore   <--  points earned by completing today's listItems
```

A `listItem` holds **no reference** to the habit or task it came from. It is a copy. The only link back to a habit is the item's `name`, which several features match on (see [gotchas](gotchas.md#name-matching)).

### `habItem` (`:36`): a recurring habit template

| Field | Default | Meaning |
| --- | --- | --- |
| `id` | new UUID | Identity |
| `name` | `"Habit"` | Shown on the row; also the join key to its list items |
| `descript` | `""` | Description |
| `goal`, `unit` | `1`, `"Units"` | Count to reach, and its label |
| `hasCheckbox` | `false` | One-tap completion; forces `goal = 1`, `unit = "units"` |
| `hasStatus` | `false` | List items get a free-text status field |
| `hasSubtask`, `subhabits` | `false`, `[]` | Step names; when used, `goal = subhabits.count`, `unit = "subhabits"`, `hasCheckbox = false` |
| `reward` | `1` | Points |
| `startDate` | now | Interval repeats count from here |
| `repeatValue` | `1` | Repeat every N days when `useDow == false` |
| `useDow`, `dow` | `false`, all false | Repeat on chosen weekdays instead |
| `timeRegion` | `"None"` | Used by notifications |
| `colorName` | `"Default"` | One of `habitColorOptions` (`Globals.swift:27`) |
| `whichProtocol` | `"Daily"` | Protocol name |
| `order` | `0` | Manual sort order in the Habits list |

The three tracking modes (checkbox, count, steps) are enforced on save in `HabitBuilderView.addItem()` (`:537`) and `updateHabit()` (`:485`), not by the model. `init` takes a `superTask` argument and ignores it. `habItem` is marked `@available(iOS 26, *)`.

### `dow` (`:12`)

Seven booleans, `onSun` to `onSat`. Owned by a `habItem` or an `eventItem`. Not listed in the container explicitly; it is reached through those models.

### `listItem` (`:99`): one row on one day

| Field | Default | Meaning |
| --- | --- | --- |
| `id` | new UUID | Identity |
| `timestamp` | now | The day it belongs to; also the sort key of the Today list |
| `name` | `""` | Display name. A `"> "` prefix means it was scooted. |
| `isTask` | `false` | Came from a task |
| `complete`, `value`, `goal`, `unit` | `false`, `0`, `1`, `"Units"` | Progress |
| `hasCheckbox`, `hasStatus`, `statusText` | | Same meaning as on the habit |
| `notFloater` | `true` | `false` makes it a floater |
| `reward` | `1` | Points |
| `descriptor` | `""` | Description; filled for tasks only |
| `timeRegion`, `colorName`, `whichProtocol` | | Copied from the habit |
| `subhabits`, `subhabitChecked` | `[]`, `[]` | Step names and their ticks, same length |

The convenience `init(from:timestamp:)` (`:144`) builds a list item from a habit.

### `taskItem` (`:168`): a pending one-off

`id`, `name`, `descript`, `dueDate`, `goal`, `unit`, `hasCheckbox` (default `true`), `notFloater` (default `true`), `reward`. It has no time region, colour or protocol; `shuntTask` fills those with `"None"`, default and `"Daily"`.

### `eventItem` (`:195`): reminder only

`id`, `name`, `descript`, `startDate`, `repeatValue`, `useDow`, `dow`, `timeRegion`, plus `useExactTime` and `fireTime` (only the hour and minute of `fireTime` are read).

### `dayScore` (`:226`)

`day` (start of the calendar day) and `score`. One row per day that earned points. `dayData(for:)` creates it; `scoreFor(date:)` only reads.

### `habSubItem` (`:85`)

A subclass of `habItem` that is not in the container and is used nowhere. Leave it alone.

## Codable mirrors (`Globals.swift`)

| Struct | Line | Used for |
| --- | --- | --- |
| `Habit` | 288 | The bundled protocol library, and the library sheet's adopt action. Field names are prefixed `Habit…`. |
| `HabitProtocol` | 264 | A protocol: `ProtocolName`, `ProtocolDescription`, `ProtocolContent: [Habit]`. Stored as JSON under the `protocol` key. |
| `Task` | 274 | Not used by live code. |

`Habit` and `habItem` carry the same fields under different names, so a new habit field has to be added to both; see [recipes](recipes.md#add-a-field-to-habits).

## UserDefaults keys

| Key | Type | Written by | Read by |
| --- | --- | --- | --- |
| `protocol` | JSON `[HabitProtocol]` | `indexProtocols` (`Globals.swift:970`) | Habits, Protocols, library sheet |
| `DailyTaskPopulate?` | Date | `MainListTab.checkDate` (`:657`, `:663`) | same |
| `lastCelebrationDay` | Date | `checkDayCompletion` (`Globals.swift:825`) | same |
| `seenWelcome` | Bool | Welcome sheet button (`MainListTab.swift:581`) | `MainListTab`, `ContentView` |
| `notifFreq` | Int, hours, clamped 1-24 | Settings | `generateNotifications` |
| `miniNotifFreq` | Int, minutes, clamped 10-120, unset means 20 | Settings | `generateNotifications` |
| `hourlyNotifsDisabled`, `miniNotifsDisabled` | Bool | Settings (`@AppStorage`) | `generateNotifications` |
| `wakeupTime` | Date, unset means 7:00 | Settings | `generateNotifications` |
| `bedtime` | Date | Settings | nothing |
| `hideTabLog`, `hideTabGraphs`, `hideTabProtocolList`, `hideTabEvents` | Bool | Settings | `TabBar` |
| `hideTabSettings`, `hideTabHabits`, `hideTabHub`, `hideTabTest` | Bool | nothing | counted in Settings' tab total only |
| `habitList` | JSON `[Habit]` | nothing | the dead `HabitDetailView` |

There is no stored daily goal; see [scoring](scoring.md).

## Deleting

- `deleteEntity(withUUID:)` removes a list item. It does not adjust the day score.
- `deleteEntityTask(withUUID:)` removes a task.
- `deleteEntityEvent(withUUID:)` removes an event and rebuilds notifications.
- A habit is deleted inline at `HabitBuilderView.swift:460`. Its existing list items stay.
