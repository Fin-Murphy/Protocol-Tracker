# Protocol Tracker
One of the greatest causes of unnecessary mental strain every day is decision fatigue. In a primarily knowledge-work society like ours, few can afford to waste precious cognitive power on the chore of figuring out what they have to do every day, which is why I designed and built Protocol Tracker.
Protocol Tracker allows the user to completely automate the timing and tracking of both repeating habits and unique tasks, and combines them in a sleek interface that eliminates the need for sprawling task spreadsheets or manually writing down your habits and to-dos every day by hand. It consolidates all initiatives into an easy-to-read list every day that you can follow and check off as you complete them.
This application attempts to combine bullet journalling and Emacs Org Mode functionalities for maximum ease of use when deciding what to do each day. Forget the hassle of manual to-do lists, and keeping up with calendars — Protocol Tracker allows you to "set it and forget it".

---

## Overview

Protocol Tracker is a native iOS application that unifies recurring habits and one-off tasks into a single, automatically populated daily checklist. Rather than asking the user to re-author their to-do list every morning, Protocol Tracker derives the day's agenda from a library of user-defined "protocols" — bundles of habits with their own repeat cadences — plus any non-recurring tasks that come due that day.

The user defines what they want to do *once*; the app handles *when* it shows up, *how* it's tracked, and *what* counts as complete from then on.

## The Problem Being Solved

Modern knowledge workers fight three overlapping problems every day:

1. **Decision fatigue** — re-deciding the same routines every morning burns cognitive budget that should go toward actual work.
2. **Tool sprawl** — to-dos live in Google Calendar, Canvas, Gmail, Notion, Obsidian, Slack, and a dozen other inboxes. Reconciling them is a chore in itself.
3. **Bookkeeping overhead** — bullet journalling and Org Mode both work, but they require manual upkeep that scales poorly.

Protocol Tracker's design intent is to absorb all of that. The current iOS app solves problems (1) and (3) for self-managed routines, and the longer-term roadmap (see *Ultimate Goal* below) extends it to (2) by pulling in tasks from external services.

## The original goal

The long-term vision was a **universal task unifier**: Protocol Tracker should pull in to-dos from disparate applications — Google Calendar, Canvas, Gmail, Notion, Obsidian, Slack, and so on — and merge them with the user's habits into one unified daily list. This way the user doesn't need to bobble between applications, maintain multiple tabs, or constantly context-switch, significantly reducing scheduling overhead and dramatically increasing productivity.

### Bundled Protocol Library

The app ships with an `AppDefinedProtocolLibrary` of curated routines — currently the *Huberman Daily* protocol (morning sunlight, delayed caffeine, hydration, exercise, evening light exposure, sleep environment, etc.). Users can adopt these as-is or use them as a starting template.

## A sorry end

I was originally planning on fully building out this application, but the skills I gained getting to this stage did turn out to be useful and now I'm working on a similar application that achieves all of the goals that this one had but on a much larger scale. See Reverb_Public in my repository list for the new and improved goal app. 
