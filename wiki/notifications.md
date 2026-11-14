# Notifications

One function owns every local notification: `generateNotifications(modelContext:)` at `Globals.swift:65`. It removes all pending requests and schedules a fresh set of non-repeating ones. Scheduling goes through `HabitNotificationManager.shared.scheduleReminder(at:identifier:title:body:)` (`:43`).

Permission is requested in `MainListTab`'s `.onAppear` (`MainListTab.swift:624`).

## When it runs

| Trigger | Where |
| --- | --- |
| Launch | `ContentView.swift:112` |
| App returns to foreground | `ContentView.swift:115` |
| Any progress change | end of `addValue`, `completeHabit`, `subValue` |
| Day rollover | `MainListTab.checkDate` (`:655`) |
| A settings change | `SettingsView` (toggles, frequencies, wake time) |
| An event is added, edited or deleted | `EventBuilderView` (`:314`, `:359`), `deleteEntityEvent` |

It does not run when a habit or task is added, edited or deleted, or when an item is scooted or deleted. Those changes reach notifications at the next trigger above.

## The budget

iOS keeps at most 64 pending requests. The four passes fill it in priority order.

| Pass | Lines | Slots | Covers |
| --- | --- | --- | --- |
| 1. Wake-up nudges | 73-90 | 6, always | The next three days |
| 2. Exact-time events | 92-144 | up to 58 | The rest of today |
| 3. Hourly digest | 179-211 | what is left, at most 23 | The rest of today |
| 4. Mini check-ins | 215-242 | `min(40, 64 − 6 − hourly − events)` | The rest of today |

If both `hourlyNotifsDisabled` and `miniNotifsDisabled` are set, the function returns after pass 2 (`:148`).

## Pass 1: wake-up nudges

For each of the next three calendar days, two requests at `wakeupTime` + 10 minutes and + 60 minutes. Unset `wakeupTime` means 7:00.

- Identifiers: `wake-nudge <dayOffset> 10`, `wake-nudge <dayOffset> 60`.
- Titles: "Good morning", "Your list is waiting". Body: "Open Protocol Tracker to load today's list."
- Nothing is scheduled for today. Since every rebuild starts from tomorrow, opening the app on a given day removes that day's nudges.

The nudges exist because the list is only populated when the app is opened; see [daily-cycle](daily-cycle.md).

## Pass 2: events

Fetches every `eventItem` and keeps those due today, using the same test as habits (interval from `startDate`, guarded with `max(repeatValue, 1)`, or weekday flags).

An event with `useExactTime == true` gets its own request at today's `fireTime` hour and minute, if that moment is still ahead.

- Identifier: `event-reminder <uuid>`. Title: the event name. Body: the description, or the name if empty.

Events without an exact time join the hourly digest instead.

## Pass 3: hourly digest

Starting at the next full hour and stepping by `notifFreq` hours (clamped to 1-24) until midnight. Each sendout lists:

- every incomplete list item for today whose `timeRegion` is empty, `"None"`, or the region of that hour, as `name (value/goal)`;
- every due event without an exact time, under the same region rule, as `name`.

An empty body means no request. Identifier: `daily-habit-reminder <hour> 0`. Title: "Incomplete Task!".

## Pass 4: mini check-ins

One request every `miniNotifFreq` minutes (clamped to 10-120; unset means 20) until midnight, each naming a single item: the first incomplete item in the current hour's region, else the first with no region, else the first of all (`topIncompleteItem`, `:219`). "First" follows `timestamp` order, which is the Today list's order.

If the interval would use up the budget before midnight, it is widened for this rebuild only so the reminders spread evenly to midnight. The saved setting is not changed.

- Identifier: `mini-habit-reminder <n>`. Title: "Quick check-in!". Body: `name (value/goal)`.

## Time regions (`timeRegion(forHour:)`, `:31`)

| Hours | Region |
| --- | --- |
| 0-12 | Morning |
| 13-15 | Noon |
| 16-19 | Afternoon |
| 20-23 | Evening |

Region names are plain strings compared with `==`; the valid set is `timeRegionOptions` (`:25`).

## Settings that feed this

`notifFreq`, `miniNotifFreq`, `hourlyNotifsDisabled`, `miniNotifsDisabled`, `wakeupTime`; see [data-model](data-model.md#userdefaults-keys). `bedtime` is stored and not used.

## Things to know before changing it

- "Today's items" here means list items stamped today and not complete (`:169`-`:175`). Scooted markers (`"> "` names) are incomplete and stamped today, so they are included in digests.
- A fetch failure inside the function is a `fatalError` (`:246`).
- The function fetches every `listItem` and every `eventItem` on each call, and it is called on every tap that changes progress.
