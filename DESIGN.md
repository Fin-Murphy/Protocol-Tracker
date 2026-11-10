# Protocol Tracker redesign spec: "Daybook"

Scope: appearance, layout and navigation only. No changes to SwiftData models, UserDefaults keys, scoring, population or notification logic. Every interaction below calls a function that already exists.

## 1. Direction

**Daybook.** The app is a paper ledger for the day: warm off-white pages, near-black ink, and exactly one accent, a koi vermilion, reserved for progress and selection. Titles are set in serif like a printed daybook, numbers in monospace like ledger columns, and everything else in the plain system face. Surfaces are flat with hairline borders; there are no shadows, gradients or filled chrome. The existing bullet-journal vocabulary (open item, done item, migrated `>` item) is kept and drawn properly instead of typed as characters.

The source material suggested this through a dominant recurring seven (the week), a length equal to the number of quarter-hours in a day, several doubled letters (paired strokes), and a fish name and a poet's name hidden inside it (koi vermilion on ink).

**Signature element: the Double Rule.** Two parallel 2pt lines, 3pt apart, in accent. In a ledger a double underline means "this total is final". The first line is the day's progress bar; the second is drawn only when the day's goal is met. The same pair, shortened to 16pt, marks the selected tab. It appears nowhere else.

## 2. Tokens

Put these in one new file, `ScatterBrainVVD/Theme.swift` (the project uses file-system-synchronised groups, so a new file needs no project-file edit). Build colours with a `UIColor { traits in … }` provider, the same way `habitPair` does, so they re-resolve on a light/dark switch. Replace every use of the `ForeColor` global and remove the two `.colorScheme(.light)` modifiers (tab bar, date bar).

### Colour

| Token | Light | Dark | Use |
|---|---|---|---|
| `bg` | `#F6F2EA` | `#121110` | Screen background, tab bar |
| `surface` | `#FFFDF8` | `#1C1B19` | Cards, list rows, form rows, sheets |
| `sunken` | `#ECE6DA` | `#282623` | Text fields, chips, pressed state |
| `text1` | `#1B1A17` | `#F2EEE6` | Titles, row names, values |
| `text2` | `#5C574E` | `#B4ADA1` | Meta lines, completed names, unselected tabs |
| `text3` | `#6F685D` | `#969085` | Placeholders, empty-state icons, scooted rows. Never on `sunken` in light mode |
| `separator` | `#DDD5C6` | `#34312D` | Hairlines, card borders, progress track |
| `control` | `#8A8377` | `#857F75` | Unchecked control outline when habit colour is Default |
| `accent` | `#B93A0E` | `#FF7A45` | Double Rule, selected states, primary button fill, links |
| `onAccent` | `#FFFFFF` | `#1B1A17` | Text/icons on accent or destructive fills |
| `success` | `#2F6B3F` | `#6FCF8A` | Complete swipe action, "Added" confirmation |
| `warning` | `#8A5A00` | `#F0B45A` | Tomorrow swipe action, tab-limit notice |
| `destructive` | `#B3261E` | `#FF6B60` | Delete/Remove |

Set `.tint(accent)` at the root in `ContentView`.

### Type

All fonts are system text styles so they scale with Dynamic Type. Sizes are the default-size values.

| Role | SwiftUI | Size / weight |
|---|---|---|
| Screen title | `.system(.title, design: .serif, weight: .semibold)` | 28 semibold |
| Detail title | `.system(.title2, design: .serif, weight: .semibold)` | 22 semibold |
| Row name / body | `.system(.body)` | 17 regular |
| Button label | `.system(.headline)` | 17 semibold |
| Meta | `.system(.footnote)` | 13 regular |
| Section label | `.system(.caption, weight: .semibold)`, uppercase, tracking 1.0, `text2` | 12 semibold |
| Value (counts, points, times, dates in columns) | `.system(.subheadline, design: .monospaced, weight: .medium)` | 15 medium |
| Big value (score, counter on detail) | `.system(.title, design: .monospaced, weight: .medium)` | 28 medium |
| Tab label | `.system(.caption2, weight: .medium)` | 11 medium |

### Space, shape, stroke

- Spacing scale: 4, 8, 12, 16, 24, 32, 48. Screen side margin 16. Gap between cards/sections 24. Row inner padding 12 vertical, 16 horizontal.
- Radii: 6 (task check control, tags), 10 (buttons, fields, chips), 16 (cards). Use `.continuous` corners.
- Strokes: 1pt hairline (separators, card borders), 1.5pt (check-control outline), 2pt (Double Rule, progress arc, check mark).
- Shadows: none. Materials: none except what system sheets apply. Elevation is shown by `surface` on `bg` plus a 1pt `separator` border.

### Motion

| What | Animation |
|---|---|
| Check control fill + check mark draw | 180ms `easeOut` |
| Row moving between To do and Done | `.spring(response: 0.35, dampingFraction: 0.85)` |
| Progress rule width, progress arc | 350ms `easeInOut` |
| Closing rule (day complete) | draws left to right, 600ms `easeOut`, after 150ms delay |
| Tab indicator | slides with `matchedGeometryEffect`, `.spring(response: 0.3, dampingFraction: 0.8)` |
| Button press | opacity to 0.7, 100ms |
| Sheets, pushes | system default |

Tab content switches instantly (no cross-fade). Nothing else animates.

## 3. Habit colours

Key names are unchanged; only the values returned by `habitColor(_:)` change. All values measure at least 4.9:1 on `bg` and `surface` in their own mode.

| Key | Light | Dark |
|---|---|---|
| `Default` | `text1` `#1B1A17` | `text1` `#F2EEE6` |
| `Red` | `#A8322A` | `#F0857A` |
| `Orange` | `#8F5A00` | `#E8B04A` |
| `Green` | `#2E6B3E` | `#7FCB8F` |
| `Teal` | `#14696B` | `#5CC6C2` |
| `Blue` | `#2B5A9E` | `#86B0F2` |
| `Purple` | `#6B4A9E` | `#BBA0F0` |
| `Pink` | `#A83868` | `#F08AB4` |

Change in use: habit colour no longer tints the row name (names are always `text1`). It colours the check control, the dot in habit lists, and the filled cells in Graphs. For `Default`, an unchecked control outline uses `control` instead of `text1`.

## 4. Components

### Checklist row

Height: minimum 56. Background `surface`, 1pt `separator` between rows, no disclosure chevron (hide the `NavigationLink` indicator). Layout, left to right: check control (26pt visual, 44×44 hit area), 12 gap, text column (name, then optional meta line), spacer, optional trailing value.

- **Check control shape encodes type** (replaces the `h.square`/`t.square` icons and the `•`, `☐`, `☑` characters): habits are a circle, tasks a rounded square (radius 6).
- **Meta line** (`Meta` style, `text2`), parts joined with " · ", omitted when empty: `+N pts` (reward), time region when not `None`, `Carries over` for floaters, status text when `hasStatus` and non-empty.

| State | Control | Name | Trailing |
|---|---|---|---|
| Plain (checkbox, incomplete) | 1.5pt outline in habit colour | `text1` | none |
| With progress/goal (`hasCheckbox == false`, no subhabits) | `separator` 1.5pt track plus a 2pt arc in habit colour, trimmed to `value/goal`, starting at 12 o'clock | `text1` | `value/goal` in Value style, `text2`; unit goes in the meta line |
| With subhabits | same arc as progress | `text1` | `value/goal`; meta line starts with `N steps` |
| Completed | filled with habit colour, 2pt check mark in `bg` | `text2`, strikethrough | value stays, `text2` |
| Scooted (`"> "` prefix) | no control; `chevron.right` 13pt semibold in `text3`, centred in the same 44×44 slot, not tappable | name with the `"> "` prefix stripped for display only, `text3`, no strikethrough | none. Meta line reads `Moved to tomorrow` |
| Floater (`notFloater == false`) | as its type | `text1` | as its type; meta line includes `Carries over` |

Interactions:

- Tap the row body: push Item detail (as today).
- Tap the check control:
  - checkbox item, incomplete: `completeHabit` + `playCustomHaptic()`.
  - checkbox item, complete: `subValue(1)` (what the detail screen's checkbox does today).
  - progress item, incomplete: `addValue(1)`.
  - subhabit items, completed progress items, scooted items: same as tapping the row.
- Swipe trailing: `Complete` (`checkmark`, `success`), calls `completeHabit` + haptic as today; then `Tomorrow` (`arrow.right`, `warning`), calls `scootItem`, shown only when `notFloater == true && complete == false`.
- Swipe leading: `Delete` (`trash`, `destructive`), calls `deleteEntity` as today.

The list has two groups, as today: incomplete then complete. Add a section label `TO DO` above the first and `DONE · n` above the second; hide a label when its group is empty.

### Date bar and day score (one header block on the Today screen)

Padding 16 sides, 12 top.

1. Row 1: leading, a button that opens the date picker sheet: weekday in Screen title style ("Monday"), below it the date in Meta style, `text2` ("9 November 2026"), followed by an 11pt `chevron.down` in `text3`. Trailing: `chevron.left` and `chevron.right` buttons, 44×44 each, 17pt semibold `text1`, moving one day (as `<<` and `>>` do today).
2. Row 2 (12 below): score in Big value style `text1`, immediately followed by `/goal pts` in Value style `text2`. Trailing: when the selected day is not today, a `Today` chip (Value style label, `sunken` fill, radius 10, height 32 inside a 44 hit area) that sets `SelectedDate = Date()`. When the day is complete, the trailing slot instead shows `DAY CLOSED` in Section label style, `accent` (the Today chip takes priority on other days and the label moves under the score).
3. Double Rule (8 below), full content width. Progress rule: 2pt, track `separator`, fill `accent`, width `min(score/goal, 1)`; when goal is 0 show the empty track. Closing rule: 2pt `accent`, 3pt beneath, present only when `goal > 0 && score >= goal`.

Date picker sheet: `.sheet` with `.presentationDetents([.medium, .large])`, graphical `DatePicker` limited to `displayedComponents: .date`, toolbar `Done`.

### Day-complete celebration

Trigger in the view: when `goal > 0 && score >= goal` changes from false to true while the selected day is today. Sequence: closing rule draws (600ms), score digits change to `accent` for 1.2s then return to `text1`, `DAY CLOSED` label fades in (200ms), one `UINotificationFeedbackGenerator().notificationOccurred(.success)`. No confetti, no modal. The closed state (both rules, label) is persistent for any day that meets its goal, without animation. `celebrationProcedure()` and the `lastCelebrationDay` latch are untouched.

### Tab bar

Height 56 above the safe area, background `bg`, 1pt `separator` on its top edge. Items share width equally. Each item: Double Rule indicator slot (two 16×2pt `accent` bars, 3pt apart, only on the selected tab; 6 below the top edge), icon 22pt, label always visible (today labels show only on the selected tab). Selected: `text1`, symbol `.fill` variant. Unselected: `text2`, outline variant. Whole item is the hit target (at least 44×56). Visibility still comes from the `hideTab…` flags.

### Buttons

| Kind | Spec |
|---|---|
| Primary | height 50, full width, radius 10, fill `accent`, label Button style in `onAccent` |
| Secondary | same size, fill none, 1pt `separator` border, label `text1` |
| Destructive | as Secondary with label `destructive`; always followed by a `confirmationDialog` |
| Stepper chip | 44×44 minimum, radius 10, fill `sunken`, label Value style `text1` (e.g. `+5`) |
| Toolbar / icon | 44×44, icon 17pt semibold `text1`; text toolbar actions in `accent` |

Disabled: 40% opacity. `bckMod()` (3pt black/white outline) is retired; restyle it as the Card below so untouched call sites still look right.

### Form fields and pickers

Forms stay native `Form`, with `.scrollContentBackground(.hidden)`, `bg` behind, `surface` row backgrounds, Section label style headers in sentence-length plain words (no trailing colons). Text fields: `text1`, placeholder `text3`. Multi-line notes: `TextEditor`, minimum height 96, no extra border. Two-or-three-way choices use a segmented `Picker` instead of stacked toggles. Colour picker: a row of eight 28pt circles (44×44 targets) filled with each habit colour; selected has a 2pt `text1` ring at 3pt offset; accessibility label is the colour name. Day-of-week picker: seven 40pt circular chips labelled S M T W T F S (Sunday first, as stored), `sunken` when off, `accent` with `onAccent` letter when on; accessibility labels are full day names.

### Card

`surface` fill, radius 16, 1pt `separator` border, padding 16. Labelled rows inside a card: label in Meta style `text2` on the left, value in body `text1` right-aligned, 1pt separators between.

### Empty state

Centred in the available space: SF Symbol at 32pt `text3`, 12 gap, title in Button style `text1`, 4 gap, one sentence in Meta style `text2` (max width 280, centred), 16 gap, optional Secondary button at intrinsic width (minimum 44 high).

| Screen | Symbol | Title | Sentence | Button |
|---|---|---|---|---|
| Today | `text.book.closed` | Nothing on this page | Habits appear here on the days they repeat. Tasks appear on their date. | `Add a habit` → `.Protocols` |
| Habits | `repeat` | No habits yet | Create one, or adopt a set from the library. | `Browse library` |
| Tasks | `checkmark.square` | No tasks waiting | Tasks wait here until their date, then move to Today. | `New task` |
| Events | `bell` | No events | Events send reminders without adding to your checklist. | `New event` |
| Graphs | `chart.dots.scatter` | Nothing to chart | Add a habit and its week appears here. | none |
| Protocols | `list.bullet.rectangle` | No protocols | A protocol is a named group of habits. | `Browse library` |

## 5. Screens

Common frame for every tab: `bg` full-bleed, a header row with the Screen title leading and icon buttons trailing (16 side padding, 12 top, 8 bottom), then content. Each tab's content sits in a `NavigationStack` (replacing `NavigationView`) with the system navigation bar hidden at the root and shown on pushed screens. All create/edit forms are `.sheet`s with `Cancel` (leading) and `Save` (trailing, `accent`, semibold) in the toolbar; this replaces the fixed 300×700 black overlay panels, the `closeButton`, and the in-form Save buttons. Use one form view per entity for both create and edit (titles `New habit` / `Edit habit`, etc.).

### Today (`MainListTab`, `.HUB`)

- Header: the date bar block above (replaces the single centred line `<< date - (x/y Points) >>`).
- List: checklist rows in `TO DO` and `DONE · n` groups, plain list style, `bg` behind.
- Empty state when the day has no items.
- First launch (`seenWelcome`): a `.sheet` at `.medium` detent instead of the outlined overlay. Title `Welcome to Protocol Tracker`. Body: `Build habits and tasks, and each day's checklist fills itself in. Tick things off to earn points; the day closes when every point is earned. Habits, Tasks and Graphs are along the bottom, and more tabs can be turned on in Settings.` Primary button `Get started` (same action as today).

**Item detail** (pushed from a row; today `navLinkContent`). Scrolling content, 16 margins, 24 between blocks:

1. Detail title, `text1`, strikethrough + `text2` when complete. Under it a meta line: type (`Habit` or `Task`), `+N pts`, time region, `Carries over`.
2. Status (only when `hasStatus`): Section label `STATUS`, text field on `sunken`, radius 10, height 44, full width (today it is 100pt wide inside two nested outlines). Same `setStatus` call on change.
3. Description (when non-empty): Card with the text. Same source as today (`displayHabitDescription` for habits, `descriptor` for tasks). Remove the fixed 350pt width.
4. Progress block, pinned visually as the last block:
   - Checkbox item: Primary button `Mark done`; when complete, Secondary button `Mark not done`. Same `addValue(1)` / `subValue(1)` calls.
   - Progress item: centred Big value `value / goal` with the unit beneath in Meta style, a 2pt progress bar (track `separator`, fill habit colour), then one row of Stepper chips in the order `−10 −5 −1 +1 +5 +10`, with the 5s shown only when `goal > 5` and the 10s only when `goal > 10` (same rules as today).
   - Subhabit item: `value / goal` as above, then a Card of rows, each a 44pt-high button with a small circle control (habit colour) and the subhabit name; same toggle logic as today.
5. `Move to tomorrow` Secondary button, only when `notFloater == true && complete == false` (today a bare text link "Move this item to tomorrow?").

### Habits (`HabitBuilderView`, `.Protocols`)

- Header: title `Habits`; trailing `books.vertical` (opens the protocol library; today an unlabelled `chevron.down`) and `plus` (new habit).
- Below header: segmented `Picker` `All | By protocol` bound to `displayByProtocol` (replaces the "Display by Protocol" toggle).
- List rows: 10pt dot in habit colour, name (`text1`), meta line with the schedule summary (`Every day`, `Every N days`, or the chosen day initials such as `M W F`) and time region; trailing `goal unit` in Value style `text2` (omit for checkbox habits). In By-protocol mode each protocol name is a Section label. Drag-to-reorder (`onMove`) is kept in both modes.
- **Habit detail** (pushed): Detail title in habit colour; a Card of labelled rows `Protocol`, `Starts`, `Goal`, `Repeats`, `Time of day`, `Reward`; a second Card with the description when non-empty; a third listing subhabits when present; then Secondary `Edit habit` and Destructive `Remove habit` (dialog: `Remove this habit?`, `Remove` / `Cancel`; then the same delete call and pop). Replaces the list of "Item is part of…" sentences.
- **Habit form** (sheet), sections in order:
  1. `Name`: text field. `Colour`: swatch row.
  2. `Tracking`: segmented `Checkbox | Count | Steps`. Checkbox sets `HabitHasSubTaskSet = false, HabitHasCheckboxSet = true`; Count sets both false and reveals `Goal` (number) and `Unit` fields; Steps sets `HabitHasSubTaskSet = true` and reveals the subhabit editor (one text field per step with a trailing `minus.circle` in `destructive`, and an `Add step` row).
  3. `Schedule`: `Starts` date picker (compact); segmented `Every N days | Days of week` bound to `HabitUseDOWSet`; then either an `Interval` number field with footer `1 = daily, 7 = weekly` or the day-of-week chips; `Time of day` menu picker with footer `Narrows reminder notifications`.
  4. `Details`: `Protocol` text field; `Notes` text editor; `Reward` number field with footer `Points for completing`; toggle `Include status update`.
- `Save` calls the existing `addItem()` / `updateHabit(…)`.

### Tasks (`TaskBuilderView`, `.Goals`, tab label was "Log")

- Header: title `Tasks`; trailing `plus`.
- List rows: rounded-square glyph (outline, `control`), name, trailing due date in Value style `text2` (today the row shows the name only).
- **Task detail** (pushed): Detail title; Card with `Goal` (omit for checkbox tasks), `Due`; Card with the description; Primary `Move to today's list` (calls `shuntTask`; was "Shunt Task"); Secondary `Edit task`; Destructive `Remove task` with dialog.
- **Task form** (sheet): `Name`; `Tracking` segmented `Checkbox | Count` bound to `TaskHasCheckboxSet`, Count reveals `Goal` and `Unit`; `Date` picker; toggle `Carry over until done`, whose `isOn` is the inverse of `TaskIsntFloatingSet` (was "Task doesn't Persist"), footer `Stays on Today until you finish it`; `Notes`; `Reward`. Fixes the edit form's "Save Habit" label.

### Events (`EventBuilderView`, `.Events`)

- Header: title `Events`; trailing `plus`.
- List rows: `bell` 15pt `text2`, name, trailing fire time or time region in Value style `text2` (as today).
- **Event detail** (pushed): Detail title; Card with `Starts`, `Repeats`, `Notifies` (time, or `During <region>`); Card with description; Secondary `Edit event`; Destructive `Remove event` with dialog.
- **Event form** (sheet): `Name`; `Schedule` (identical component to the habit form: start date, interval or day chips); `Notify` segmented `Exact time | Time of day` bound to `EventUseExactTimeSet`, revealing a time picker or the region menu with footer `Joins that part of the day's reminder digest`; `Notes`.

### Graphs (`GraphTabView`, `.Settings`)

- Header: title `Graphs`.
- Week bar: `chevron.left` (44×44), centred range in Value style (`3 Nov – 9 Nov`), `chevron.right` (disabled at the current week, as today).
- One Card containing the grid. Column header: weekday initial over day number, Value style at caption size, `text2`; today's column in `accent`. One row per habit, minimum height 44: name (`text1`, one line, truncating; flexible width, minimum 96), then seven 28pt cells:
  - completed: 18pt filled circle in the habit colour;
  - on the list that day but not completed: 18pt 1.5pt outline in `control`;
  - not on the list that day: 4pt dot in `separator`.
  The third state is new and view-only: `DayPoint` gains a `scheduled` flag (`match != nil`). Each cell's accessibility label reads e.g. `Tuesday, done`.
- Replaces the outlined box of `checkmark.square` icons.

### Settings (`SettingsView`, `.Calendar`)

- Header: title `Settings`. Form sections:
  1. `Hourly digest`: toggle `Hourly reminders`; row `Every` with a trailing number field and the word `hours`; footer `1 to 24`.
  2. `Mini reminders`: toggle `Mini reminders`; row `Every` … `minutes`; footer `10 to 120`.
  3. `Sleep`: `Wake up` and `Bedtime` time pickers.
  4. `Tabs`: one row each for Tasks, Graphs, Protocols, Events. The row label is a button that opens that screen (as today, works even when the tab is hidden) and shows a trailing `chevron.right` in `text3`; at the far right a `Toggle` (labels hidden) replaces the square/checkmark icon, bound to the same flag with the same enable/disable rules. Footer: `N of 6 tabs shown`; when at the limit, add `Turn one off to add another.` in `warning`.
- Keyboard `Done` toolbar stays. Same keys, same clamps, same `generateNotifications` calls.

### Protocols (`ProtocolListView`, `.ProtocolList`)

- Header: title `Protocols`; trailing `books.vertical` (opens the library; was `+`).
- List rows: protocol name, trailing habit count in Value style `text2`.
- Pushed protocol page: Detail title, then a Card listing its habits, each with the colour dot and name.

### Protocol library (`ProtocolLibraryModal`)

A `.sheet` at `.large` with its own `NavigationStack`, title `Library`, toolbar `Done`. Replaces the 300×700 black panel.

- Root: one row per bundled protocol, name plus `N habits` in Meta style.
- Protocol page: Primary button `Add all N habits`, then the list of its habits.
- Habit page: Detail title, Card with goal/unit and description from the `Habit` struct, Primary button `Add this habit`.
- After either add succeeds, the button label becomes `Added` with a `checkmark`, fill `success`, for 1.5s, then reverts (today there is no feedback).

### Habit detail (`Models/HabitDetailView.swift`)

This struct is not referenced anywhere; the detail users actually see is the one pushed from the Habits list, specified above. Leave the file alone.

## 6. Navigation and IA

Same eight destinations, same enum, same flags, same six-tab limit. Three changes: order, labels, and icons.

| Position before | Position after | Enum case | Screen | Label before → after | Icon after | Flag |
|---|---|---|---|---|---|---|
| 3 | 1 | `.HUB` | `MainListTab` | Hub → **Today** | `text.book.closed` | `hideTabHub` |
| 2 | 2 | `.Protocols` | `HabitBuilderView` | Habits | `repeat` | `hideTabHabits` |
| 4 | 3 | `.Goals` | `TaskBuilderView` | Log → **Tasks** | `checkmark.square` | `hideTabLog` |
| 5 | 4 | `.Settings` | `GraphTabView` | Graphs | `chart.dots.scatter` | `hideTabGraphs` |
| 6 | 5 | `.ProtocolList` | `ProtocolListView` | Protocols | `list.bullet.rectangle` | `hideTabProtocolList` |
| 7 | 6 | `.Events` | `EventBuilderView` | Events | `bell` | `hideTabEvents` |
| 1 | last | `.Calendar` | `SettingsView` | Settings | `gearshape` | `hideTabSettings` |
| n/a | n/a | `.Test` | `TestView` | unchanged, still hidden, not restyled | | `hideTabTest` |

Where each existing function lives:

| Function | Before | After |
|---|---|---|
| Change day, pick a date, see score/goal | Centred date line on Hub | Date bar block on Today (plus new `Today` chip) |
| Complete an item | Swipe; detail screen | Swipe; detail screen; tap check control |
| Add/subtract progress, tick subhabits, set status | Item detail | Item detail (progress also +1 from the row control) |
| Move to tomorrow | Text link on item detail | Button on item detail; swipe action |
| Delete a list item | Leading swipe | Leading swipe |
| Create / edit / remove / reorder habit | Habits: `+` overlay, detail, drag | Habits: `plus` sheet, detail, drag |
| Group habits by protocol | Toggle on Habits | Segmented control on Habits |
| Protocol library | `chevron.down` on Habits; `+` on Protocols | `books.vertical` on both; empty-state buttons |
| Create / edit / remove task, move task to today | Tasks: `+` overlay, detail ("Shunt Task") | Tasks: `plus` sheet, detail (`Move to today's list`) |
| Create / edit / remove event | Events | Events, sheets |
| Weekly graph, page weeks | Graphs | Graphs |
| Notification settings, sleep times, tab visibility, open hidden tabs | Settings | Settings |
| Welcome message | Overlay on Hub | Sheet on Today |

## 7. Accessibility

- Contrast (measured): `text1` at least 13.0:1 and `text2` at least 5.7:1 on every surface in both modes; `text3` at least 4.9:1 on `bg` and `surface` (4.4:1 on light `sunken`, so it is not used there); `accent`, `success`, `warning`, `destructive` and all habit colours at least 4.9:1 on `bg` and `surface`; `onAccent` on `accent` 5.7:1 light, 6.7:1 dark. Control outlines are at least 3.0:1.
- Colour is never the only signal: completion also changes the glyph and adds strikethrough; type is the control's shape; graph cells differ in size and fill.
- Dynamic Type: every font is a text style; no fixed heights on text containers (row and button heights are minimums). At accessibility sizes (`dynamicTypeSize.isAccessibilitySize`) the checklist row's trailing value moves under the name, labelled card rows stack label over value, and the date bar's score row wraps under the date. Tab labels and graph column headers cap at `.xxLarge` and get `.accessibilityShowsLargeContentViewer()`. Row names wrap to at most 3 lines.
- Targets: every button, chip, swatch, check control and tab item has a hit area of at least 44×44 (use `.contentShape` with padding where the visual is smaller).
- VoiceOver: a checklist row is one element reading `<name>, <habit|task>, <value of goal unit>, <done|not done>` with custom actions `Complete`, `Move to tomorrow`, `Delete`; the check control is a separate button labelled `Mark <name> done` / `not done` / `Add one`. The Double Rule is exposed as one element: `Day progress, 7 of 12 points` plus `, day closed`. Tab items carry `.isSelected`. Icon-only buttons have labels (`Previous day`, `Next day`, `New habit`, `Browse library`, …).
- Reduce Motion (`accessibilityReduceMotion`): the closing rule and check mark appear with a 150ms opacity fade instead of drawing; the tab indicator does not slide; progress widths change without animation. The success haptic still plays.

## 8. Implementation order

1. **Theme**: `Theme.swift` tokens, new `habitColor` values, root tint, retire `ForeColor` and `.colorScheme(.light)`, restyle `bckMod` as Card.
2. **Tab bar**: order, labels, icons, Double Rule indicator.
3. **Today**: date bar block with Double Rule, checklist row in all states, groups, swipes, empty state, celebration.
4. **Item detail**.
5. **Sheets for forms**: shared schedule/tracking/colour components, then Habit form, Habits list and detail.
6. **Tasks**, then **Events** (reuse step 5 components).
7. **Settings**.
8. **Graphs**.
9. **Protocols** and **Library** sheet.
10. Welcome sheet, VoiceOver labels and Dynamic Type pass across all screens.

Steps 1 to 4 deliver most of the visible change; the app is shippable after any step.
