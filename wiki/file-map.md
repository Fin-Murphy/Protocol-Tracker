# File map

All Swift source is under `ScatterBrainVVD/`. Line counts are from commit `697a06e`.

## Entry and routing

| File | Lines | Holds |
| --- | --- | --- |
| `ScatterBrainVVDApp.swift` | 20 | `@main`. Attaches the SwiftData container for `habItem`, `listItem`, `taskItem`, `dayScore`, `eventItem`. |
| `ContentView.swift` | 125 | Root view. Switches screens on `selectedTab` (`:36`-`:103`), draws `TabBar`, and rebuilds notifications on launch and on foreground (`:112`-`:119`). |
| `Models/TabBar.swift` | 122 | The `Tabs` enum (`:10`) and the custom tab bar. |

## Logic

| File | Lines | Holds |
| --- | --- | --- |
| `Globals.swift` | 977 | Nearly all business logic as free functions. See the function index below. |
| `BuilderViews/Datum.swift` | 235 | Every SwiftData model. See [data-model](data-model.md). |
| `AppProtocolLibrary.swift` | 195 | `AppDefinedProtocolLibrary` (`:48`), the bundled protocols. See [protocols](protocols.md). |
| `Theme.swift` | 150 | Colour and type tokens, button styles, the `.card()` modifier. See [views](views.md#theme). |

## Screens (`BuilderViews/`)

| File | Lines | Screen | Live |
| --- | --- | --- | --- |
| `MainListTab.swift` | 770 | Today. Also holds the day rollover, populate and deshunt. | yes |
| `HabitBuilderView.swift` | 693 | Habits: list, detail, create and edit form. | yes |
| `TaskBuilderView.swift` | 324 | Tasks: list, detail, create and edit form. | yes |
| `EventBuilderView.swift` | 385 | Events: list, detail, create and edit form. | yes, tab hidden by default |
| `SettingsView.swift` | 221 | Settings: notification frequencies, wake and bed times, tab toggles. | yes |
| `GraphTabView.swift` | 195 | Graphs: per-habit completion grid for one week. | yes |
| `ProtocolListView.swift` | 125 | Protocols: habits grouped by protocol. | yes, tab hidden by default |
| `TestView.swift` | 34 | Placeholder text. | routed but unreachable |
| `CalendarView.swift` | 61 | Old calendar pane. | no, its only use is commented out at `ContentView.swift:38` |
| `GoalSetView.swift` | 23 | Old daily-goal setter. | no, referenced nowhere |

## Shared view components (`Models/`)

| File | Lines | Holds | Live |
| --- | --- | --- | --- |
| `DaybookComponents.swift` | 473 | `SectionLabel`, `ScreenHeader`, `IconButton`, `CardRow`, `RowCard`, `TextCard`, `EmptyState`, `CheckControl`, `DoubleRule`, `DoubleRuleMark`, `NotesEditor`, `ColourSwatchRow`, `DayOfWeekChips`, `ScheduleSection`, the `.daybookForm()` and `.formSheetToolbar()` modifiers, and `scheduleSummary()` (`:465`). | yes |
| `DateBarView.swift` | 245 | The Today header: date, chevrons, date-picker popover, score and goal, the Double Rule. | yes |
| `ProtocolLibraryModal.swift` | 196 | Sheet for browsing and adopting bundled protocols. | yes |
| `HabitDetailView.swift` | 41 | Old habit detail; reads a `habitList` key nothing writes. | no |
| `ListLabelView.swift` | 57 | Old row label. | no |

## `Globals.swift` function index

| Function | Line | Purpose | Page |
| --- | --- | --- | --- |
| `timeRegion(forHour:)` | 31 | Hour to time-region name | [notifications](notifications.md) |
| `HabitNotificationManager.scheduleReminder` | 43 | Adds one non-repeating notification request | [notifications](notifications.md) |
| `generateNotifications` | 65 | Clears and rebuilds all pending notifications | [notifications](notifications.md) |
| `HabitProtocol`, `Task`, `Habit` structs | 264, 274, 288 | Codable mirrors of the models | [data-model](data-model.md) |
| `habitColor(_:)` | 404 | Palette name to light/dark `Color` | [views](views.md#theme) |
| `scootItem` | 420 | Move a list item to the next day | [daily-cycle](daily-cycle.md) |
| `deleteEntity`, `deleteEntityTask`, `deleteEntityEvent` | 455, 471, 487 | Delete a list item, task or event by UUID | [data-model](data-model.md) |
| `shuntTask`, `shuntTodaysTasks` | 509, 534 | Task to list item | [daily-cycle](daily-cycle.md) |
| `displayHabitDescription` | 556 | Look up a habit's description by **name** | [gotchas](gotchas.md) |
| `daysBetween` | 572 | Whole days between two dates | [daily-cycle](daily-cycle.md) |
| `setEncodable`, `getDecodable` | 579, 588 | JSON in UserDefaults | [data-model](data-model.md) |
| `saveContext` | 599 | `modelContext.save()`, `fatalError` on failure | [recipes](recipes.md) |
| `dayData(for:)`, `scoreFor(date:)` | 618, 635 | Get-or-create and read-only day score | [scoring](scoring.md) |
| `goalTotal(for:)`, `goalFor(date:)` | 652, 658 | The derived daily goal | [scoring](scoring.md) |
| `addValue`, `completeHabit`, `subValue` | 670, 711, 757 | Progress mutations | [scoring](scoring.md) |
| `setStatus` | 789 | Save an item's free-text status | [data-model](data-model.md) |
| `celebrationProcedure`, `checkDayCompletion` | 801, 812 | Day-complete event and its once-a-day latch | [scoring](scoring.md) |
| `progressFeedback`, `playCustomHaptic` | 832, 857 | Haptics and system sounds | [scoring](scoring.md) |
| `generateTestHabitData` | 889 | Backfill 14 days of random items; called nowhere | [recipes](recipes.md) |
| `indexProtocols` | 926 | Reconcile the stored protocol list with the habits | [protocols](protocols.md) |

Unused leftovers in `Globals.swift`: `closeButton` (`:349`), `backgroundMod` and `.bckMod()` (`:358`), `forward_Calendar` and `backward_Calendar` (`:329`, used only by the dead `CalendarView`), `ForeColor` (`:386`, used only by `CalendarView` and `TestView`).

## Not source

| Path | What |
| --- | --- |
| `ScatterBrainVVD.xcodeproj/` | Project file. Also contains committed per-user Xcode state (`xcuserdata`, `UserInterfaceState.xcuserstate`), which changes whenever the author opens Xcode. |
| `ScatterBrainVVD/Assets.xcassets/` | App icon and accent colour. |
| `ScatterBrainVVD/ScatterBrainVVD.entitlements` | App sandbox and read-only user-selected files. |
| `ScatterBrainVVDTests/`, `ScatterBrainVVDUITests/` | Template tests only. |
| `.DS_Store` files | Committed macOS metadata; ignore. |
