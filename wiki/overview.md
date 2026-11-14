# Overview

## What the app does

The user defines habits (recurring) and tasks (one-off) once. Each day the app builds that day's checklist from them. Ticking an item earns its points; the day "closes" when every point on the day's list is earned. Local notifications remind the user of what is left. Events are reminder-only entries that never appear on the checklist.

The stated purpose (README, kanban boards) is to remove daily decision fatigue, borrowing from bullet journalling and Emacs Org Mode.

## Status

- Feature development has stopped. The README points to `Reverb_Public` as the successor.
- 236 commits, June 2025 to November 2026. `design-branch` is fully merged into `main`.
- No package manager, linter, CI or external dependency. A commented-out Supabase client remains at `Globals.swift:257`.
- The two test targets contain only Xcode template tests.

## Build

Taken from `CLAUDE.md`; not run while writing this wiki.

```sh
xcodebuild -project ScatterBrainVVD.xcodeproj -scheme ScatterBrainVVD \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Replace `build` with `test` to run the template tests. Facts from `project.pbxproj`:

| Setting | Value |
| --- | --- |
| Scheme | `ScatterBrainVVD` (the only one) |
| App bundle id | `com.vividDev.Protocol-Tracker` |
| App deployment target | iOS 26 |
| Test targets' deployment target | iOS 18.5 |
| Marketing version | 9 |
| Swift version | 5.0 |
| Project format | `objectVersion = 77`, file-system-synchronised groups |

Because groups are synchronised with the file system, a new `.swift` file placed in `ScatterBrainVVD/` joins the app target without editing `project.pbxproj`.

## Vocabulary

| Term | Meaning |
| --- | --- |
| Habit | A recurring template (`habItem`). Repeats every N days or on chosen weekdays. |
| Task | A one-off with a due date (`taskItem`), waiting in the Tasks tab. |
| List item | A row on one day's checklist (`listItem`). Made from a habit or a task. |
| Event | A reminder-only recurrence (`eventItem`). Produces notifications, never a list item. |
| Protocol | A named group of habits. It is only a string on each habit (`whichProtocol`). |
| Populate | Create today's list items from the habits due today. |
| Shunt | Convert a task into a list item on today's list, deleting the task. |
| Deshunt | Convert an unfinished task list item back into a task. |
| Scoot | Move an unfinished list item to the next day, leaving a `"> "`-prefixed marker behind. |
| Floater | A list item with `notFloater == false`. It follows the user from day to day until completed. |
| Time region | `"None"`, `"Morning"`, `"Noon"`, `"Afternoon"` or `"Evening"`; used only by notifications. |
| Reward | The points an item is worth. |
| Day score | Points earned on a calendar day (`dayScore`). |
| Subhabits | Named steps inside a habit; the item's goal equals the number of steps. |

## Misleading names

| Name | What it actually is |
| --- | --- |
| Repo `Protocol-Tracker` | Every target, scheme and source folder is called `ScatterBrainVVD`. |
| `Models/` folder | Reusable **view** components. The data models are in `BuilderViews/Datum.swift`. |
| `BuilderViews/` folder | All tab screens, plus the data models. |
| `Tabs.Calendar` | The Settings screen. |
| `Tabs.Settings` | The Graphs screen. |
| `Tabs.Protocols` | The Habits screen. |
| `Tabs.Goals` | The Tasks screen. |
| `Tabs.HUB` | The Today screen. |
| `notFloater` | A negative flag: `true` means the item stays on its day. |
| `hideTabLog` | Hides the Tasks tab (it was once labelled "Log"). |
| `testTasksForSillyness()` | Re-stamps floaters to today each time the Today list appears (`MainListTab.swift:675`). |
| `listItem.descriptor` vs `habItem.descript` | The same idea, a description, under two names. |
| `"DailyTaskPopulate?"` | The UserDefaults key holding the date of the last populate. The `?` is part of the key. |

The full tab routing table is in [views](views.md#tab-routing).
