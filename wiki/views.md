# Views

SwiftUI throughout. There is no `TabView`: `ContentView` picks a screen with an `if`/`else if` chain on `selectedTab` and draws a custom `TabBar` underneath. Appearance follows `DESIGN.md` ("Daybook"); read that file before any visual change.

## Tab routing

The enum is at `Models/TabBar.swift:10`; the chain is at `ContentView.swift:36`-`:103`; the bar's entries are built at `TabBar.swift:50`.

| Enum case | Screen | Bar label | Icon | Visibility |
| --- | --- | --- | --- | --- |
| `.HUB` | `MainListTab` | Today | `text.book.closed` | always |
| `.Protocols` | `HabitBuilderView` | Habits | `repeat` | always |
| `.Goals` | `TaskBuilderView` | Tasks | `checkmark.square` | `hideTabLog` (shown by default) |
| `.Settings` | `GraphTabView` | Graphs | `chart.dots.scatter` | `hideTabGraphs` (shown by default) |
| `.ProtocolList` | `ProtocolListView` | Protocols | `list.bullet.rectangle` | `hideTabProtocolList` (hidden by default) |
| `.Events` | `EventBuilderView` | Events | `bell` | `hideTabEvents` (hidden by default) |
| `.Calendar` | `SettingsView` | Settings | `gearshape` | always |
| `.Test` | `TestView` | none | none | no bar entry and no Settings row; unreachable |

The app opens on `.HUB`. Bar order is the row order above.

Settings shows a toggle row for Tasks, Graphs, Protocols and Events (`SettingsView.swift:145`-`:148`). Tapping a row's name opens that screen even when its tab is hidden (`TabToggleRow`, `:179`). At most six tabs may be on (`maxActiveTabs`, `:48`); the count includes the three always-on tabs.

Screen state is not preserved across tab switches: each switch builds the screen again, so `.onAppear` runs every time.

## Screens

### Today: `BuilderViews/MainListTab.swift`

| Piece | Line | Role |
| --- | --- | --- |
| `MainListTab` | 533 | The screen. Owns rollover (`checkDate`), `populateTasks`, `deshuntTask`, the welcome sheet, the notification permission request. |
| `DateBarView` (in `Models/`) | 41 | Header: date, previous/next day, date picker, score and goal, Double Rule. |
| `dayListView` | 319 | The list for the selected day; query built in `init`. Swipe trailing: Complete, Tomorrow. Swipe leading: Delete. |
| `navLinkLabel` | 25 | A row's text and trailing value. |
| `navLinkContent` | 211 | Item detail, pushed with `navigationDestination(item:)`. |
| `valueModView` | 88 | Progress bar and ± chips for count items. |
| `subhabitChecklistView` | 158 | Step checklist for steps items. |

`SelectedDate` lives in `ContentView` and is bound into `MainListTab` and `DateBarView`. Changing it rebuilds `dayListView` and `DateBarView` with new queries.

### Habits: `BuilderViews/HabitBuilderView.swift`

List of habits sorted by `order`, drag to reorder (`move`, `:669`), a "Display" control to group by protocol (`:401`), a detail page per habit (`habitDetail`, `:312`), and one form used for both create and edit (`habitFormSheet`, `:198`). The form's fields are `@State` on the screen (`:23`-`:47`), loaded by `loadForm` (`:233`) and cleared by `resetForm` (`:207`). Save paths: `addItem` (`:537`), `updateHabit` (`:485`). The library button opens `ProtocolLibraryModal`.

### Tasks: `BuilderViews/TaskBuilderView.swift`

List sorted by name, detail (`taskDetail`, `:125`) with "Move to today's list", and one form for create and edit. Save paths: `addTask` (`:285`), `updateTask` (`:267`).

### Events: `BuilderViews/EventBuilderView.swift`

Same shape as Tasks. The form reuses `ScheduleSection` and adds a "Notify" choice between an exact time and a time of day. Save paths: `addEvent` (`:317`), `updateEvent` (`:284`); both rebuild notifications.

### Graphs: `BuilderViews/GraphTabView.swift`

One row per habit, seven day cells, pageable by week (`weekOffset`). A cell is found by matching list items to the habit **by name** on that day (`weekPoints`, `:172`). Queries every `listItem`.

### Protocols: `BuilderViews/ProtocolListView.swift`

Reads the `protocol` key and lists each protocol's habits (`habits(in:)`, `:19`).

### Settings: `BuilderViews/SettingsView.swift`

Hourly digest toggle and interval, mini check-in toggle and interval, wake-up and bedtime pickers, tab toggles. Every notification-related control calls `generateNotifications`.

## Shared components: `Models/DaybookComponents.swift`

| Component | Line | Use |
| --- | --- | --- |
| `SectionLabel` | 14 | Small caps-style section header |
| `ScreenHeader` | 33 | Screen title with optional trailing buttons |
| `IconButton` | 60 | 44pt symbol button with an accessibility label |
| `CardRow`, `RowCard`, `TextCard` | 84, 122, 149 | Card layouts for detail pages |
| `EmptyState` | 166 | Symbol, title, sentence, one button |
| `CheckControl` | 217 | The check box / progress ring on rows and steps |
| `DoubleRule`, `DoubleRuleMark` | 272, 303 | The signature progress rule, and its short form under the selected tab |
| `.daybookForm()`, `.formSheetToolbar(…)` | 319, 327 | Form styling and the Cancel/Save toolbar |
| `NotesEditor`, `ColourSwatchRow` | 344, 357 | Form fields |
| `DayOfWeekChips`, `ScheduleSection` | 389, 421 | Schedule fields shared by the habit and event forms |
| `scheduleSummary(…)` | 465 | "Every day", "Every 3 days", "M W F" |

## Theme

`Theme.swift` holds every colour and font as static tokens on `enum Theme` (`:12`).

- Colours: `bg`, `surface`, `sunken`, `text1`, `text2`, `text3`, `separator`, `control`, `accent`, `onAccent`, `success`, `warning`, `destructive`. Each is a light/dark pair that re-resolves when the system appearance changes.
- Fonts: `screenTitle`, `detailTitle` (serif), `body`, `button`, `meta`, `sectionLabel`, `value`, `bigValue` (monospaced), `tabLabel`, `icon`. All are system text styles, so they scale with Dynamic Type.
- Styles: `PrimaryButtonStyle` (`:97`), `SecondaryButtonStyle` (`:111`), `ChipButtonStyle` (`:131`), `FadeButtonStyle` (`:145`), and `.card()` (`:76`).

Habit colours are separate: `habitColor(_:)` at `Globals.swift:404` maps a name from `habitColorOptions` to its own light/dark pair, and falls back to `Theme.text1`.

Use tokens, never literal colours or fixed font sizes. `ForeColor` (`Globals.swift:386`) is a retired alias kept for two dead views.

## Accessibility conventions already in the code

Rows combine into one element with a spoken label (`rowLabel`, `MainListTab.swift:378`) and custom actions for Complete, Move to tomorrow and Delete. Animations check `accessibilityReduceMotion`. Layouts check `dynamicTypeSize.isAccessibilitySize`. Touch targets are at least 44pt. Keep these when adding controls.
