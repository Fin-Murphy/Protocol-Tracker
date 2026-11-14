# Recipes

Each recipe lists every place a change has to touch. The lists come from reading the code; none has been exercised by a build.

## Conventions to follow in any change

- Put logic in a free function in `Globals.swift` that takes `modelContext: ModelContext`. Views call it.
- A function that changes stored data ends with `saveContext(modelContext:)` (`Globals.swift:599`).
- If the change affects which items are incomplete today, or any event, also call `generateNotifications(modelContext:)`.
- Change a day's score only when the item's `timestamp` is today; copy the check used in `addValue` (`Globals.swift:674`).
- Give every new SwiftData property a default value, as every existing one has. There is no migration plan.
- Use `Theme` tokens and the components in `DaybookComponents.swift`; see [views](views.md).
- Do not commit changes under `ScatterBrainVVD.xcodeproj/**/xcuserdata/`.

## Add a field to habits

1. `habItem` in `BuilderViews/Datum.swift:36`: the property, with a default.
2. If rows need it, `listItem` (`:99`) too, and copy it in:
   - `listItem.init(from:timestamp:)` (`Datum.swift:144`);
   - `scootItem` (`Globals.swift:420`), which builds its copy field by field.
3. `Habit` struct (`Globals.swift:288`): add it as an optional with a `nil` default, as `HabitTimeRegion` and `HabitColor` are, so the bundled library still compiles unchanged.
4. `HabitBuilderView.swift`: a `@State` (`:23`-`:47`), the form control, `resetForm` (`:207`), `loadForm` (`:233`), `addItem` (`:537`, including the reset block at its end, `:643`-`:663`), `updateHabit` (`:485`).
5. `ProtocolLibraryModal.incorporateHabit` (`:157`).
6. Update [data-model](data-model.md), and `CLAUDE.md` / `projSpecs.md` if they list the field.

## Add a field to tasks

1. `taskItem` (`Datum.swift:168`).
2. `shuntTask` (`Globals.swift:509`) to carry it onto the list item, and `MainListTab.deshuntTask` (`:749`) to carry it back.
3. `TaskBuilderView.swift`: `@State`, form control, `resetForm` (`:114`), the edit-button load block in `taskDetail` (`:153` onward), `addTask` (`:285`), `updateTask` (`:267`).

## Add a new way to change progress

Write it beside `addValue` in `Globals.swift`. Keep the same shape: read `wasComplete`, apply the today rule, call `checkDayCompletion` for today's items, call `progressFeedback` unless the day just closed, then `saveContext` and `generateNotifications`. See [scoring](scoring.md).

## Add a setting

1. A control in `SettingsView.swift`, backed by `@AppStorage` (as `hourlyNotifsDisabled` is, `:24`) or by a `@State` saved with `UserDefaults.standard.set` (as `wakeupTime` is, `:129`).
2. Read it where it is used. If notifications depend on it, call `generateNotifications` when it changes.
3. Add the key to the table in [data-model](data-model.md#userdefaults-keys).

## Add a screen and tab

1. A case in `Tabs` (`Models/TabBar.swift:10`).
2. A branch in the chain in `ContentView.swift` (`:36`-`:103`).
3. In `TabBar.swift`: an `@AppStorage("hideTab…")` flag (`:26`-`:33`) and an entry in `entries` (`:50`).
4. In `SettingsView.swift`: the same flag (`:34`-`:41`), its place in `activeTabCount` (`:50`), and a `TabToggleRow` (`:145`).
5. Add the row to the table in [views](views.md#tab-routing) and to `DESIGN.md` section 6.

Six tabs is the limit, and three are always on.

## Add a time region

`timeRegionOptions` (`Globals.swift:25`) and `timeRegion(forHour:)` (`:31`). The habit and event forms read the options list. Regions are compared as strings, so spelling must match everywhere.

## Add a habit colour

`habitColorOptions` (`Globals.swift:27`) and a case in `habitColor(_:)` (`:404`) with a light and a dark hex. `DESIGN.md` section 3 sets the contrast requirement for the pair.

## Add a SwiftData model

1. Define it in `BuilderViews/Datum.swift`.
2. Add it to the container at `ScatterBrainVVDApp.swift:17`.
3. Add it to the preview containers (`ContentView.swift:124`, the `#Preview` at the end of `GraphTabView.swift`).
4. Add it to [data-model](data-model.md).

## Add a protocol to the bundled library

See [protocols](protocols.md#adding-a-protocol-to-the-library).

## Get test data for the Graphs screen

`generateTestHabitData(modelContext:)` (`Globals.swift:889`) backfills the previous 14 days with one random item per habit. Nothing calls it. Call it from a temporary button, run once, and remove the call.

## Check a change

There are no real tests. After a change, build with the command in [overview](overview.md#build) and walk through by hand, in the simulator:

1. Create a checkbox habit, a count habit and a steps habit due today; each should appear on Today.
2. Complete each; the header score should rise by its reward, and the day should close when all are done.
3. Undo one; the score should fall.
4. Create a task due today; it should move from Tasks to Today.
5. Scoot an item; today's goal should drop and the copy should be on tomorrow's page.
6. Change the device date forward a day, reopen the app, and confirm the new day's list.

State in your report which of these you ran and which you could not.
