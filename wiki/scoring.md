# Scoring, the daily goal and completion

All functions are in `Globals.swift`.

## The model

- Every list item has a `reward`.
- **Goal for a day** = the sum of `reward` over that day's list items, skipping scooted ones (names starting `"> "`). `goalTotal(for:)` (`:652`) does the sum; `goalFor(date:)` (`:658`) fetches the day's items first. Nothing stores the goal.
- **Score for a day** = `dayScore.score` for that day. `dayData(for:)` (`:618`) returns the row, creating it at 0 if missing; `scoreFor(date:)` (`:635`) reads without creating.
- The day is **closed** when `goal > 0 && score >= goal`.

Scooted items are skipped so that moving something to tomorrow cannot leave today unwinnable.

## Progress mutations

Each takes the `listItem`, the `modelContext`, and `Celebrate: inout Int` (the root view's copy of today's score). Each ends with `saveContext` and `generateNotifications`.

| Function | Line | Effect |
| --- | --- | --- |
| `addValue(item:value:…)` | 670 | `value += n`. On reaching `goal` for the first time: mark complete, add `reward` to today's score, set `notFloater = true`. |
| `completeHabit(item:…)` | 711 | Jump to complete: `value = goal`, tick every subhabit, add `reward`, set `notFloater = true`. Does nothing if already complete. |
| `subValue(item:value:…)` | 757 | `value -= n`. On dropping below `goal` while complete: mark incomplete and subtract `reward`. |
| `setStatus(refItem:…)` | 789 | Saves the free-text status. No score effect. |

**The today rule.** Score changes only when the item's `timestamp` is today (`Calendar.current.isDate(…, toGranularity: .day)`). For a past or future day the same functions flip `value` and `complete` but leave every `dayScore` alone, and skip `checkDayCompletion`.

## Who calls them

| Gesture | Code | Call |
| --- | --- | --- |
| Tap the check control on a checkbox item | `MainListTab.controlTapped` (`:355`) | `completeHabit`, or `subValue(1)` if already complete |
| Tap the check control on a count item | same | `addValue(1)`; opens the detail if already complete |
| Tap the check control on a steps item | same | opens the detail |
| Swipe "Complete" | `MainListTab.swift:451` | `completeHabit` |
| Detail chips ±1, ±5, ±10 | `valueModView` (`:88`) | `addValue` / `subValue`; ±5 shown when `goal > 5`, ±10 when `goal > 10` |
| Tick a step | `subhabitChecklistView` (`:158`) | `addValue(1)` / `subValue(1)` and updates `subhabitChecked` |
| "Mark done" / "Mark not done" | `navLinkContent` (`:287`-`:300`) | `addValue(1)` / `subValue(1)` |

## Day completion

`checkDayCompletion(modelContext:)` (`:812`) runs after `addValue` and `completeHabit` on today's items:

1. If `lastCelebrationDay` (UserDefaults) is today, return `false`.
2. If today's goal is 0, or score is below goal, return `false`.
3. Store today in `lastCelebrationDay`, call `celebrationProcedure()` (`:801`), return `true`.

So the celebration fires at most once per calendar day, even if items are added after the goal was met.

## Feedback tiers

| Tier | When | What | Code |
| --- | --- | --- | --- |
| 1 | Progress without completing | Light impact, system sound 1104 | `progressFeedback(completed: false)` (`:832`) |
| 2 | An item completes | Success notification haptic, system sound 1113 | `progressFeedback(completed: true)` |
| 3 | The day closes | Custom Core Haptics pattern (about 1.4 s), system sound 1025 | `celebrationProcedure` → `playCustomHaptic` (`:857`) |

When tier 3 fires, the caller skips its own tier 1 or 2 feedback.

## What the header shows

`Models/DateBarView.swift` draws score and goal for the **selected** day: the score from a `@Query` over all `dayScore` rows, the goal from `goalTotal` over that day's items. Its own `celebrate()` (`:102`) is animation only (the Double Rule closing, a score flash), triggered by `.onChange(of: dayState)` (`:236`). It is separate from `celebrationProcedure` and its latch.

`Celebrate` in `ContentView` (`:22`) is seeded from `scoreFor(today)` when the Today screen appears (`MainListTab.swift:634`) and overwritten by the mutation functions. Nothing reads it for display any more.

## Things that change the goal or score without a mutation function

- Adding or deleting a list item changes that day's goal immediately.
- Deleting a **completed** item lowers the goal but leaves its points in the score; see [gotchas](gotchas.md#deleting-a-completed-item-keeps-its-points).
- Scooting an item lowers today's goal by its reward.
