# Protocols and the bundled library

## What a protocol is

A protocol is a name shared by a group of habits. Each `habItem` carries it as the string `whichProtocol` (default `"Daily"`). There is no protocol model in SwiftData.

A second copy exists in UserDefaults under the key `protocol`: a JSON array of `HabitProtocol` (`Globals.swift:264`), each with `ProtocolName`, `ProtocolDescription` and `ProtocolContent`. This array is an index for the screens that group by protocol. For user habits its `ProtocolContent` is empty; membership is always worked out from `whichProtocol`.

## `indexProtocols(modelContext:)` (`Globals.swift:926`)

Reconciles the stored array with the habits that exist:

1. Remove any stored protocol that no habit names.
2. Append a `HabitProtocol` (empty description) for any `whichProtocol` value not yet stored.
3. Save the array. If the key was missing, save an empty array and stop; the next call fills it.

Called from: `HabitBuilderView` on appear (`:478`), after a habit is added (`:665`) and after one is edited (`:375`); `ProtocolLibraryModal.incorporateHabit` (`:191`).

Views keep their own `@State` copy of the array and re-read the key after each call (for example `HabitBuilderView.swift:479`). If you call `indexProtocols` somewhere new, re-read the key in the view afterwards or the grouping will be stale.

## Where protocols show

- Habits screen, "Display" control set to group by protocol (`HabitBuilderView.swift:401`).
- Protocols screen (`ProtocolListView.swift`), which filters habits with `habits(in:)` (`:19`).
- The habit form's protocol field (free text, `HabitProtocolSet`).

## The bundled library

`AppDefinedProtocolLibrary` (`AppProtocolLibrary.swift:48`) is a constant `[HabitProtocol]` built from `Habit` structs. It currently holds one protocol, **Huberman Daily**, with nine habits: morning walk and sunlight, delayed caffeine, hydration, exercise, lunch, dinner, evening light, sleep schedule, sleep environment.

`Models/ProtocolLibraryModal.swift` shows the library in a sheet. The user can adopt a whole protocol (`incorporateProtocol`, `:149`) or a single habit (`incorporateHabit`, `:157`). Adopting a habit:

1. builds a `habItem` from the `Habit` struct, with `startDate` = today;
2. copies colour, weekday flags and subhabits;
3. inserts and saves it;
4. calls `indexProtocols`, then the `onIncorporate` callback so the presenting screen re-reads the `protocol` key.

Adopting does **not** create today's list item. The habit first appears on the checklist at the next rollover (compare `HabitBuilderView.addItem`, which does create it; see [daily-cycle](daily-cycle.md#other-ways-a-list-item-is-created)). Adopting the same habit twice creates two habits with the same name.

## Adding a protocol to the library

Append a `HabitProtocol` to `AppDefinedProtocolLibrary`. Give every `Habit` in it the protocol's name in `HabitProtocol` and a distinct `HabitOrdering`. Optional fields (`HabitTimeRegion`, `HabitColor`, `HabitSubhabits`) default to none. The block of commented-out struct definitions at the top of the file is an old copy; the live definitions are in `Globals.swift`.
