# Protocol Tracker wiki

A map of this repository for agents. Read this page first, then open only the pages your task needs. The wiki describes the code at commit `697a06e` on `main`; where a page and the code disagree, the code is right and the page needs fixing (see [SCHEMA](SCHEMA.md)).

Protocol Tracker is a native SwiftUI iOS app (Xcode project name **ScatterBrainVVD**) that fills a daily checklist from recurring habits and one-off tasks. It has no dependencies, no backend and no real tests. Feature work has stopped; the author's successor project is `Reverb_Public`.

## Pages

| Page | Read it when you need to |
| --- | --- |
| [overview](overview.md) | Know what the app does, its vocabulary, how to build it, and which names are misleading |
| [file-map](file-map.md) | Find which file holds something, or check whether a file is live or dead |
| [data-model](data-model.md) | Touch a SwiftData model, a Codable struct, or a UserDefaults key |
| [daily-cycle](daily-cycle.md) | Change how items appear, carry over, or move between days |
| [scoring](scoring.md) | Change points, the daily goal, completion, or the celebration |
| [notifications](notifications.md) | Change anything about local notifications |
| [views](views.md) | Change a screen, the tab bar, a shared component, or the theme |
| [protocols](protocols.md) | Change protocol grouping or the bundled protocol library |
| [recipes](recipes.md) | Make a common change and want the list of places to edit |
| [gotchas](gotchas.md) | Avoid known bugs, traps, and out-of-date documents |
| [SCHEMA](SCHEMA.md) | Edit this wiki |
| [log](log.md) | See what changed in the wiki and when |

## Five facts to hold before editing code

1. **Three item types, one checklist.** `habItem` is a template, `taskItem` is a pending one-off, `listItem` is a row on a specific day. Only `listItem` appears on the checklist. See [data-model](data-model.md).
2. **Business logic lives in `Globals.swift`** as free functions that take `modelContext`. Views call them. See [file-map](file-map.md).
3. **The day rolls over in one place:** `MainListTab.checkDate()`, run when the Today screen appears. See [daily-cycle](daily-cycle.md).
4. **The daily goal is derived, never stored:** it is the sum of `reward` over that day's `listItem`s. See [scoring](scoring.md).
5. **Names lie.** The `Tabs` enum cases, the `Models/` folder, and several documents do not mean what they say. See [overview](overview.md#misleading-names) and [gotchas](gotchas.md#documents-that-are-out-of-date).

## Other documents in the repository

- `CLAUDE.md`: agent guidance, mostly accurate; drift is listed in [gotchas](gotchas.md#documents-that-are-out-of-date).
- `DESIGN.md`: the "Daybook" visual redesign spec (colours, type, components, screens). Authoritative for appearance.
- `ScatterBrainVVD/projSpecs.md`: older data-flow notes; several sections are stale.
- `ProTrack.md`, `ProTrack To-Do.md`: Obsidian kanban boards with the backlog. `ProTrack.md` is the newer one.
- `README.md`: the public pitch and project status.
