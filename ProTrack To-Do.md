---

kanban-plugin: board

---

## Product Backlog

- [ ] # CENTRAL FUNCTION - hub for all kinds of tasks like budgeting, task allocation, habits, calendar functions, etc.
- [ ] Add Birfday gift notifs
- [ ] Add specific point-score methodologies specific to students
- [ ] Add specific categories of habits Like Workout that will add extra fields to the habit display in the main view like rest period timer, 1rm calculator, training max and percentages calculator, etc.
- [ ] Change status to a string variable
- [ ] Add junk about gamification to the misison statements
- [ ] Add subtasking
- [ ] Randomly chosen task each day is a "supertask" that gives more points. However, you never know which task it is, so you have to complete all tasks to find out.
- [ ] Finish reading Actionable Gamification
- [ ] Remember app purpose: To reduce decision fatigue as much as possible, and incorporate gamification into the design as much as possible. 1
- [ ] - add functionalities for notating sleep/wake timing, other optimal stiff
- [ ] - Add different panels that can be activated or deactivate by the users whim. Panels like Budget panel, Goals panel, etc. These should be accesible to activate/deactivate from a settings panel.
- [ ] - Add calendar view
- [ ] - Add a panel for displaying task data (Tables, graphs, etc.)
- [ ] - Add reward mechanisms
- [ ] Notifs?
- [ ] Personal Law pane
- [ ] Add the ability to sync from Google Calendar
	
	Items synced from google calendar have the specification Event and the symbology
	
	```
	* Event 
	```
- [ ] Time of day functionalities
	- Time of day
		- Time region
			- Morning
			- Noon
			- Afternoon
			- Evening
		- Specific time
			- Call to builtin time picker
- [ ] Revise mission statements in app, in app store, and on website to include Protocols as one of the main functionalities
- [ ] Add a symbol library to display on habits
- [ ] Add ability to assign protocols different colors
- [ ] - Add end date selector for a habit


## Sprint Backlog

- [ ] ### Main function - Gamification
- [ ] Associate point scores with days when flipping backwards (new data item)
- [ ] - Point graphs over time
- [ ] Change the saving mechanism for the habit status value to navigation backwards so that whenever you close the habit pane it saves the current value.
- [ ] - Habit streak tracking
- [ ] - Punishments for not meeting the points for the day
- [ ] Add a Goals tab that lets you assign each habit to a specific goal and then see as you progress towards that goal
- [ ] ### Main function - Protocols
- [ ] Gamification - "Intermittent positive feedback"
- [ ] - Intermittent positive reinforcement
- [ ] - Scoreboarding
- [ ] - Graphing
- [ ] - Task completion fanfare
- [ ] - Total habit completion fanfare
- [ ] - Rewards
- [ ] - Custom roll tables for task rewards
- [ ] - Custom roll tables for habit rewards
- [ ] - Custom roll tables for item completion
- [ ] - Rolls for random habits


## In-Progress

- [ ] Add "Routines" where you join together tasks that typically get performed in unison
- [ ] ADD FRIENDING CAPABILITIES
- [ ] Hitting move to tomorrow moves an item its location to the day after the current date, not its own timestamp. easy fix
- [ ] ADD STUDY POINTS


## COMPLETED

- [ ] potential bug, loading from protocol and then deleting deletes the tasks in the protocol???
	> Resolved: Not a bug, I'm just a dumbass
- [ ] Instead of an entire extra pane for calendar, add a button that will pop up a date picker to let you jump to a desired date in the datebar
- [ ] Change "floater" tasks to be "persistent" tasks - all tasks need to be schedulable, but instead of getting shunted back to the task list at the end of the day, they stick around until they are completed, and then they stick to that day.
- [ ] Add settings for determining daily goal
- [ ] - Add Point totals


***

## Archive

- [ ] Add function to deactivate edit mode upon back navigation in the habit menu
- [ ] Revamp the Pre-name images to accurately reflect the bullet journalling key:
	`• Task x Completed task > Migrated task (moved forward) < Scheduled task (moved to future log) — Note ○ Event * Priority/Important ! Inspiration/Idea`
- [ ] Rename the Task page Future Log and improve asthetics
- [ ] Make it so that you can still complete habits post and pre, but they just don't modify their respective day point scores
- [ ] Review [[Bullet journalling]] for how to imp
- [ ] Make a toggle to determine whether or not a habit/task persists until completion or whether it sticks to a specific day.
- [ ] Add ability to add multiple points when doing habit completion
- [ ] Fix Protocol pane not correctly ordering items when adding them to the habitlist
- [ ] Fix the PopulateTasks throwing habits into the checklist without ordering them
- [ ] - Research if there are possibilities other than userdefaults for saving and loading task lists
- [ ] Add protocol load ability
- [ ] Fix list so that items are reorder-able (not sorted in any way)
- [ ] fix move() function to work with cireData
- [ ] Ensure that all viewContexts get saved so that the Protocol view indexes properly, and that newly created habits added by the HabitBuilder and automatically populated for the date get properly saved and don't evaporate upon exiting the app or unexpected closure
- [ ] Refactor HabitBuilder to use coreData
- [ ] Refactor MainListTab to use CoreData
- [ ] fix task empty description display
- [ ] Fix completed item list so that items with no description display as such
- [ ] Run indexProtocols on habit edit (Not displaying properly at first after editing habits for some reason, fixes after reloading view)
- [ ] Cmd + shift + k to clean project
- [ ] Move ALL functions (all possible functions) to Globals
- [ ] refactor Globals
- [ ] refactor IndexProtocols
- [ ] Refactor Global functions
- [ ] refactor protocolbuilderview
- [ ] refactor MainListTab
- [ ] - Task deshunting (is this in MainListTab file view ?)
- [ ] - rmTask
- [ ] - Task shunting
- [ ] - ShuntTodaysTasks
- [ ] refactor TaskBuilderView
- [ ] refactor listLabelView
- [ ] Change DeleteEntity to a global function
- [ ] refactor HabitBuilderView
- [ ] refactor goalsetview
- [ ] Refactor calendar view
- [ ] Make a thorough backup of the entire project to roll back to just in case everything goes south
- [ ] Make a temporary new project to figure out how to use multiple types of coreData entities
- [ ] Add ability to add either individual habits OR whole protocols from the protocol library
- [ ] Fix habit detail view to accommodate for DOW repetition
- [ ] Fix populateTasks to accomodate for DOW repetition
- [ ] Begin the enormous project of refactoring all of the UserDefaults calls into CoreData calls
- [ ] ~~Make storage more reliable (figure out AppStorage)~~ Appstorage is the same as UserDefauts
- [ ] Add options to switch between interval repetition and DOW repetition
- [ ] Fix indexProtocols to remove the protocols not associated with any habits
- [ ] Add actual protocols to the library
- [ ] Add ability to add preloaded protocols to your own task list
- [ ] Add preloaded set of protocols
- [ ] Make only non-floating items pushable to tomorrow
- [ ] Change floating items to non-floating and change their date to the completion date upon completion
- [ ] Fix floating tasks uncompletable due to date not matching
- [ ] Re-index and refresh the habit list every time a habit is edited from the editing panel
- [ ] Fix the bugs with task completion
- [ ] Factor out the ForEach content inside the MainList tab!!!!!
- [ ] add buttons to scoot habits or tasks a day forwards from the current day (marks the habit / task as done with bullet journal symbology, then creates a new data item for the next day)
- [ ] Add protocols pane
- [ ] Clean up task preview view
- [ ] Add task editing view
- [ ] add free floating tasks by removing the date variable or adding another variable to display it whether or not the date matches Date() in the main ForEach
- [ ] Add a toggle for displaying habits in the habit pane either by order in the day or by their protocol
- [ ] Finish setting up the app store connect bits
- [ ] Set personal website back up and start running panes for app support
- [ ] Add subtask capabilities
- [ ] Re-order insertion items so that subtask toggle removes other options, such as task start date and other stuff.
- [ ] add ability to edit items
- [ ] Seperate out the autoshunter for dated tasks into its own file and run it every time a new task is created in case a task needs to be completed on the day of its creation.
- [ ] Fix date checker to only run if the last saved date is smaller than the current date, and will not run if the other date is larger than the current date.
- [ ] Seperate out the autoshunter for dated tasks into its own file and run it every time a new task is created in case a task needs to be completed on the day of its creation.
- [ ] Move hub tab to the center
- [ ] Code hygiene! Fix up all the crappy implimentation and repeated code that you have infesting the program right now
- [ ] Add a reorder habits on completion toggle
- [ ] Add a definitive completion fanfare and a separate point counter for each day.
- [ ] Add an option for a checkbox instead of a goal and units
- [ ] Add ability to schedule tasks
- [ ] Figure out task reordering - THIS WAS A MEGA PAIN IN TH ARSE
- [ ] Figure out how to change sort so that you can control the order of elements in a custom fashion
- [ ] Map out CoreData versus UserDefault member variables to ensure total linearity
- [ ] Fix light/dark so that all the content doesn't disappear when the screen loads
- [ ] - Add settings panel
- [ ] Add goal/unit to habit list screen
- [ ] fix habit status
- [ ] 
- [ ] - Change tasks to populate their description data item on shunt

%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[null,false,null,false]}
```
%%