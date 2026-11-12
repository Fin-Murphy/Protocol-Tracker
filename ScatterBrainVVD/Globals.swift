//
//  Globals.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/21/25.
//

import Foundation
import SwiftData
import SwiftUI
import CoreHaptics
import AudioToolbox

import UserNotifications // IMPORT FOR NOTIFICATION SERVICES


let valueRange = 1 ... 1000
let Today: Date = Date()
let calendar: Calendar = .current

// ---------------------------------------------------------------------------------------------------------------------
// ALERT SERVICE
// ---------------------------------------------------------------------------------------------------------------------

let timeRegionOptions = ["None", "Morning", "Noon", "Afternoon", "Evening"]

let habitColorOptions = ["Default", "Red", "Orange", "Green", "Teal", "Blue", "Purple", "Pink"]

// Notifications only fire on the hour, so hour granularity is exact:
// Morning 12am-12pm, Noon 12:01pm-3pm, Afternoon 3:01pm-7pm, Evening 7:01pm-11:59pm.
func timeRegion(forHour hour: Int) -> String {
    switch hour {
    case 0...12: return "Morning"
    case 13...15: return "Noon"
    case 16...19: return "Afternoon"
    default: return "Evening"
    }
}

class HabitNotificationManager {
    static let shared = HabitNotificationManager()
    
    func scheduleReminder(at fireDate: Date, identifier: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}


func generateNotifications (modelContext: ModelContext) {

    do {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // Removes all leftover notifications

        let manager = HabitNotificationManager.shared
        let now = Date()

        // -------- Wake-up nudge pass: 2 per day for the next 3 days, so a day the app is never opened still gets a reminder --------

        let nudgeCount = 6 // Reserved against the 64-pending cap; the later passes budget around it
        let nudgeBody = "Open Protocol Tracker to load today's list."
        let nudgeTitle10 = "Good morning"
        let nudgeTitle60 = "Your list is waiting"

        let wakeupTime = UserDefaults.standard.object(forKey: "wakeupTime") as? Date
        let wakeHour = wakeupTime.map { calendar.component(.hour, from: $0) } ?? 7 // Unset key = 7:00 AM, as in SettingsView
        let wakeMinute = wakeupTime.map { calendar.component(.minute, from: $0) } ?? 0

        for dayOffset in 1...3 {
            if let day = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now)),
               let wake = calendar.date(bySettingHour: wakeHour, minute: wakeMinute, second: 0, of: day) {
                manager.scheduleReminder(at: wake.addingTimeInterval(10 * 60), identifier: "wake-nudge \(dayOffset) 10", title: nudgeTitle10, body: nudgeBody)
                manager.scheduleReminder(at: wake.addingTimeInterval(60 * 60), identifier: "wake-nudge \(dayOffset) 60", title: nudgeTitle60, body: nudgeBody)
            }
        }

        // -------- Event pass: reminder-only eventItems due today (same recurrence math as populateTasks) --------

        let eventData = try modelContext.fetch(FetchDescriptor<eventItem>())

        let dformatter = DateFormatter()
        dformatter.dateFormat = "EEEE"
        let dayOfWeek = dformatter.string(from: now)

        var todaysEvents: [eventItem] = []

        for index in eventData {

            if index.useDow == false {

                let gap = daysBetween(start: calendar.startOfDay(for: index.startDate),
                                      end: calendar.startOfDay(for: now))
                if gap >= 0 && gap % max(index.repeatValue, 1) == 0 {
                    todaysEvents.append(index)
                }

            } else {

                if  (index.dow.onMon == true && dayOfWeek == "Monday") ||
                    (index.dow.onTues == true && dayOfWeek == "Tuesday") ||
                    (index.dow.onWed == true && dayOfWeek == "Wednesday") ||
                    (index.dow.onThurs == true && dayOfWeek == "Thursday") ||
                    (index.dow.onFri == true && dayOfWeek == "Friday") ||
                    (index.dow.onSat == true && dayOfWeek == "Saturday") ||
                    (index.dow.onSun == true && dayOfWeek == "Sunday")
                {
                    todaysEvents.append(index)
                }
            }
        }

        // Exact-time events get their own dedicated notification and are scheduled even
        // when both digest timescales are toggled off
        var eventCount = 0

        for index in todaysEvents {
            if index.useExactTime == true && eventCount < 64 - nudgeCount {
                let comps = calendar.dateComponents([.hour, .minute], from: index.fireTime)
                if let fireDate = calendar.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: now) {
                    if fireDate > now { // Already-past times wait for tomorrow's rebuild
                        manager.scheduleReminder(at: fireDate,
                                                 identifier: "event-reminder \(index.id.uuidString)",
                                                 title: index.name,
                                                 body: index.descript == "" ? index.name : index.descript)
                        eventCount += 1
                    }
                }
            }
        }

        let hourlyDisabled = UserDefaults.standard.bool(forKey: "hourlyNotifsDisabled")
        let miniDisabled = UserDefaults.standard.bool(forKey: "miniNotifsDisabled")
        if hourlyDisabled && miniDisabled { return } // Both timescales off; only event alarms remain scheduled

        var NotifFreq: Int = UserDefaults.standard.integer(forKey: "notifFreq")
        if NotifFreq < 1 {
            NotifFreq = 1
        } else if NotifFreq > 24 {
            NotifFreq = 24
        }

        var MiniNotifFreq: Int = UserDefaults.standard.integer(forKey: "miniNotifFreq")
        if MiniNotifFreq == 0 { // Unset key
            MiniNotifFreq = 20
        } else if MiniNotifFreq < 10 {
            MiniNotifFreq = 10
        } else if MiniNotifFreq > 120 {
            MiniNotifFreq = 120
        }

        // Timestamp sort mirrors the daily list's order, so first(where:) below = "top of the list"
        let itemData = try modelContext.fetch(FetchDescriptor<listItem>(sortBy: [SortDescriptor(\.timestamp)]))

        var todaysItems: [listItem] = []

        for index in itemData {
            if ((Calendar.current.isDate(index.timestamp, equalTo: now, toGranularity: .day) == true) && index.complete == false){ //If the item matches today...
                todaysItems.append(index)
            }
        }

        // -------- Large-scale pass: every NotifFreq hours, list of everything incomplete --------

        var hourlyCount = 0

        if !hourlyDisabled {
            var hour = calendar.component(.hour, from: now) + 1
            while hour < 24 && hourlyCount < 64 - nudgeCount - eventCount {

                var notifBody = ""

                for index in todaysItems { // Items with no time region go in every sendout; the rest only in their region's hours
                    if index.timeRegion == "" || index.timeRegion == "None" || index.timeRegion == timeRegion(forHour: hour) {
                        notifBody += "\(index.name) (\(index.value)/\(index.goal))\n"
                    }
                }

                for index in todaysEvents { // Region events join the digest under the same rule; no progress suffix
                    if index.useExactTime == false {
                        if index.timeRegion == "" || index.timeRegion == "None" || index.timeRegion == timeRegion(forHour: hour) {
                            notifBody += "\(index.name)\n"
                        }
                    }
                }

                if notifBody != "" {
                    if let fireDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) {
                        manager.scheduleReminder(at: fireDate, identifier: "daily-habit-reminder \(hour) 0", title: "Incomplete Task!", body: notifBody)
                        hourlyCount += 1
                        print("Scheduling notification for \(hour)")
                    }
                }

                hour += NotifFreq
            }
        }

        // -------- Mini pass: every MiniNotifFreq minutes, single top habit in the fire time's region --------

        if !miniDisabled && !todaysItems.isEmpty {

            // Top incomplete item for the region containing `hour`; falls back to
            // region-less items, then any incomplete item.
            func topIncompleteItem(forHour hour: Int) -> listItem? {
                let region = timeRegion(forHour: hour)
                return todaysItems.first(where: { $0.timeRegion == region })
                    ?? todaysItems.first(where: { $0.timeRegion == "" || $0.timeRegion == "None" })
                    ?? todaysItems.first
            }

            // iOS caps 64 pending requests total; nudges reserve 6, hourly pass takes at most 23
            let miniBudget = max(0, min(40, 64 - nudgeCount - hourlyCount - eventCount))
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
            // If the configured interval would burn the budget before midnight, widen it (this rebuild
            // only, never saved) so the budgeted reminders spread evenly over the rest of the day
            let miniInterval = max(TimeInterval(MiniNotifFreq * 60), endOfDay.timeIntervalSince(now) / Double(max(miniBudget, 1)))
            var fireDate = now.addingTimeInterval(miniInterval)
            var scheduled = 0

            while fireDate < endOfDay && scheduled < miniBudget {
                if let item = topIncompleteItem(forHour: calendar.component(.hour, from: fireDate)) {
                    manager.scheduleReminder(at: fireDate, identifier: "mini-habit-reminder \(scheduled)", title: "Quick check-in!", body: "\(item.name) (\(item.value)/\(item.goal))")
                    scheduled += 1
                }
                fireDate = fireDate.addingTimeInterval(miniInterval)
            }
        }

    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }

}


//---------------------------------------------------------------------------------------------------------------------
// ITEM STRUCTURES
// ---------------------------------------------------------------------------------------------------------------------


//let supabase = SupabaseClient(
//  supabaseURL: URL(string: "https://xbqsnnmvxntavytdmmzp.supabase.co")!,
//  supabaseKey: "sb_publishable_WHd5tp89cEdNp6zAybNH8A_Kui0z3t0"
//)



struct HabitProtocol: Identifiable, Codable {
    var id: UUID = UUID()
    var ProtocolName: String
    var ProtocolDescription: String
    var ProtocolContent: [Habit] = []
}

// tomas was here 12/28/25


struct Task: Identifiable, Codable {
    
    var id: UUID = UUID()
    var TaskName: String
    var TaskDescription: String
    var TaskReward: Int16
    var TaskDueDate: Date = Date()
    var TaskUnit: String
    var TaskGoal: Int16
    var TaskHasCheckbox: Bool
    var TaskNotFloater: Bool = true
}


struct Habit: Identifiable, Codable, Hashable {
    
    var id: UUID = UUID()
    var HabitName:String
    var HabitGoal:Int16
    var HabitUnit:String
    var HabitProtocol:String
    var HabitStartDate: Date = Date()
    var HabitRepeatValue: Int = 1
    var HabitDescription: String
    var HabitReward: Int16
    var HabitHasStatus: Bool
    var HabitHasCheckbox: Bool
    var HabitIsSubtask: Bool = false
    var HabitHasSubtask: Bool = false
    var HabitSuperTask: UUID?
    var HabitSubhabits: [String]? = nil

    var HabitTimeRegion: String? = nil
    var HabitColor: String? = nil

    var HabitOrdering: Int32
    
    var HabitUseDow: Bool = false
    
    var HabitOnSun: Bool = false
    var HabitOnMon: Bool = false
    var HabitOnTues: Bool = false
    var HabitOnWed: Bool = false
    var HabitOnThurs: Bool = false
    var HabitOnFri: Bool = false
    var HabitOnSat: Bool = false

    
} // END struct Task


// ---------------------------------------------------------------------------------------------------------------------
// MISC STRUCTURES AND FORMATTERS
// ---------------------------------------------------------------------------------------------------------------------

var forward_Calendar = valueRange.map {
    calendar.date(byAdding: .day, value: $0, to: Today)!
}

var backward_Calendar = valueRange.map {
    calendar.date(byAdding: .day, value: -$0, to: Today)!
}

let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()


// ---------------------------------------------------------------------------------------------------------------------
// VIEWS AND VIEW MODIFIERS
// ---------------------------------------------------------------------------------------------------------------------

var closeButton: some View {
    Image(systemName: "x.circle")
        .resizable()
        .foregroundColor(.white)
        .scaledToFit()
        .frame(width: 100,height: 24)
        .bold()
}

struct backgroundMod: ViewModifier {
    func body(content: Content) -> some View {
        content
            .card()
    }
}

extension View {
    func bckMod() -> some View {
        modifier(backgroundMod())
    }
}



//------------------------------------------------------

//                    FUNCTIONS

//------------------------------------------------------


// ---------------------------------------------------------------------------------------------------------------------
// COLOR SCHEME FUNCS
// ---------------------------------------------------------------------------------------------------------------------

// Retired: every screen now reads its colours from Theme. Kept only as an alias of Theme.text1
// for the unrouted/untouched views that still name it (CalendarView, TestView).
let ForeColor: Color = Theme.text1

private func uiColor(_ hex: UInt) -> UIColor {
    UIColor(red:   CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8)  & 0xFF) / 255,
            blue:  CGFloat( hex        & 0xFF) / 255,
            alpha: 1)
}

// Explicit light/dark pairs rather than the system colors, which are chrome-tuned and several
// of which fall under 2.5:1 on white as body text. Every pair here measures at least 4.9:1 on
// the Theme bg and surface in its own mode. The UIColor provider re-resolves on a light/dark switch.
private func habitPair(_ light: UInt, _ dark: UInt) -> Color {
    Color(UIColor { $0.userInterfaceStyle == .dark ? uiColor(dark) : uiColor(light) })
}

// Resolves a habit's stored palette name to a Color. "Default" (and any name no longer in the
// palette) falls back to the primary ink colour.
func habitColor(_ name: String) -> Color {
    switch name {
    case "Red":    return habitPair(0xA8322A, 0xF0857A)
    case "Orange": return habitPair(0x8F5A00, 0xE8B04A)
    case "Green":  return habitPair(0x2E6B3E, 0x7FCB8F)
    case "Teal":   return habitPair(0x14696B, 0x5CC6C2)
    case "Blue":   return habitPair(0x2B5A9E, 0x86B0F2)
    case "Purple": return habitPair(0x6B4A9E, 0xBBA0F0)
    case "Pink":   return habitPair(0xA83868, 0xF08AB4)
    default:       return Theme.text1
    }
}
// ---------------------------------------------------------------------------------------------------------------------
// SCOOT ITEM
// ---------------------------------------------------------------------------------------------------------------------

func scootItem(item: listItem, modelContext: ModelContext){

    let newItem = listItem(complete: false,
                           descriptor: item.descriptor,
                           goal: item.goal,
                           hasCheckbox: item.hasCheckbox,
                           hasStatus: item.hasStatus,
                           id: UUID(),
                           isTask: item.isTask,
                           name: item.name,
                           notFloater: true,
                           reward: item.reward,
                           statusText: "",
                           timeRegion: item.timeRegion,
                           timestamp: (calendar.date(byAdding: .day, value: 1, to: item.timestamp)!),
                           unit: item.unit,
                           value: 0,
                           whichProtocol: item.whichProtocol)

    newItem.colorName = item.colorName
    newItem.subhabits = item.subhabits
    newItem.subhabitChecked = Array(repeating: false, count: item.subhabits.count)

    modelContext.insert(newItem)

    item.name = ("> " + item.name)

    saveContext(modelContext: modelContext)

}

// ---------------------------------------------------------------------------------------------------------------------
// DELETE ENTITY FUNCTIONS
// ---------------------------------------------------------------------------------------------------------------------

func deleteEntity(withUUID uuid: UUID, modelContext: ModelContext) {

    var request = FetchDescriptor<listItem>(predicate: #Predicate { $0.id == uuid })
    request.fetchLimit = 1

    do {
        let results = try modelContext.fetch(request)
        if let entityToDelete = results.first {
            modelContext.delete(entityToDelete)
            try modelContext.save()
        }
    } catch {
        print("Error deleting entity: \(error)")
    }
}

func deleteEntityTask(withUUID uuid: UUID, modelContext: ModelContext) {

    var request = FetchDescriptor<taskItem>(predicate: #Predicate { $0.id == uuid })
    request.fetchLimit = 1

    do {
        let results = try modelContext.fetch(request)
        if let entityToDelete = results.first {
            modelContext.delete(entityToDelete)
            try modelContext.save()
        }
    } catch {
        print("Error deleting entity: \(error)")
    }
}

func deleteEntityEvent(withUUID uuid: UUID, modelContext: ModelContext) {

    var request = FetchDescriptor<eventItem>(predicate: #Predicate { $0.id == uuid })
    request.fetchLimit = 1

    do {
        let results = try modelContext.fetch(request)
        if let entityToDelete = results.first {
            modelContext.delete(entityToDelete)
            try modelContext.save()
        }
    } catch {
        print("Error deleting entity: \(error)")
    }

    generateNotifications(modelContext: modelContext) // Purges the dead event's pending request
}

// ---------------------------------------------------------------------------------------------------------------------
// SHUNT TASK FUNCTIONS
// ---------------------------------------------------------------------------------------------------------------------

func shuntTask (taskToShunt: taskItem, modelContext: ModelContext) {

    let newItem = listItem(complete: false,
                           descriptor: taskToShunt.descript,
                           goal: taskToShunt.goal,
                           hasCheckbox: taskToShunt.hasCheckbox,
                           hasStatus: false,
                           id: UUID(),
                           isTask: true,
                           name: taskToShunt.name,
                           notFloater: taskToShunt.notFloater,
                           reward: taskToShunt.reward,
                           statusText: "",
                           timeRegion: "None",
                           timestamp: Date(),
                           unit: taskToShunt.unit,
                           value: 0,
                           whichProtocol: "Daily")
    modelContext.insert(newItem)

    modelContext.delete(taskToShunt)
    saveContext(modelContext: modelContext)

}

func shuntTodaysTasks (modelContext: ModelContext) {
    do {
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let request = FetchDescriptor<taskItem>(predicate: #Predicate { $0.dueDate >= start && $0.dueDate < end })
        let taskData = try modelContext.fetch(request)

        for index in taskData {
            shuntTask(taskToShunt: index, modelContext: modelContext)
        }

    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }

}

// ---------------------------------------------------------------------------------------------------------------------
// UTILITIES
// ---------------------------------------------------------------------------------------------------------------------

func displayHabitDescription (identifier: String, modelContext: ModelContext) -> String {
    do {
        let habitData = try modelContext.fetch(FetchDescriptor<habItem>())

        for index in habitData {
            if index.name == identifier {
                return index.descript
            }
        }

    } catch {
        return "Failed indexing"
    }
    return "No description"
}

func daysBetween(start: Date, end: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: start, to: end)
    return components.day ?? 1
}

extension UserDefaults {
    func setEncodable<T: Codable>(_ object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            set(data, forKey: key)
        } catch {
            print("Failed to encode object: \(error)")
        }
    }
    
    func getDecodable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Failed to decode object: \(error)")
            return nil
        }
    }
} // END UserDefaults Encodable/Decodable extension

func saveContext(modelContext: ModelContext){

    do {
        try modelContext.save()
    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }


}

// ---------------------------------------------------------------------------------------------------------------------
// DAILY SCORE STORAGE
// ---------------------------------------------------------------------------------------------------------------------

// Returns the dayScore object holding the score for the given calendar day, creating an
// empty one (score 0) if none exists yet. Mutating scorers call this so every day that
// earns points owns a persistent record the calendar chevrons can read back later.
func dayData(for date: Date, modelContext: ModelContext) -> dayScore {
    let start = calendar.startOfDay(for: date)
    let end = calendar.date(byAdding: .day, value: 1, to: start)!
    var request = FetchDescriptor<dayScore>(predicate: #Predicate { $0.day >= start && $0.day < end })
    request.fetchLimit = 1

    if let existing = try? modelContext.fetch(request).first {
        return existing
    }

    let newDay = dayScore(day: start, score: 0)
    modelContext.insert(newDay)
    return newDay
}

// Read-only lookup of a day's stored score; returns 0 for days that never earned points
// (and never creates a record, so merely viewing a day doesn't litter empty dayScore rows).
func scoreFor(date: Date, modelContext: ModelContext) -> Int {
    let start = calendar.startOfDay(for: date)
    let end = calendar.date(byAdding: .day, value: 1, to: start)!
    var request = FetchDescriptor<dayScore>(predicate: #Predicate { $0.day >= start && $0.day < end })
    request.fetchLimit = 1

    return (try? modelContext.fetch(request).first?.score) ?? 0
}

// ---------------------------------------------------------------------------------------------------------------------
// DAILY GOAL
// ---------------------------------------------------------------------------------------------------------------------

// The day's goal is the combined reward of everything on that day's checklist, so hitting it
// means the docket is done. Items renamed with the "> " prefix by scootItem() were migrated to
// tomorrow and can never be completed, so they're excluded — otherwise scooting anything would
// leave the day's goal permanently out of reach.
func goalTotal(for items: [listItem]) -> Int {
    items
        .filter { $0.name.hasPrefix("> ") == false }
        .reduce(0) { $0 + $1.reward }
}

func goalFor(date: Date, modelContext: ModelContext) -> Int {
    let start = calendar.startOfDay(for: date)
    let end = calendar.date(byAdding: .day, value: 1, to: start)!
    let request = FetchDescriptor<listItem>(predicate: #Predicate { $0.timestamp >= start && $0.timestamp < end })

    return goalTotal(for: (try? modelContext.fetch(request)) ?? [])
}

// ---------------------------------------------------------------------------------------------------------------------
// VALUEMOD FUNCTIONS
// ---------------------------------------------------------------------------------------------------------------------

func addValue(item: listItem, value: Int, modelContext: ModelContext, Celebrate: inout Int){
    let wasComplete = item.complete
    var dayDone = false

    if Calendar.current.isDate(item.timestamp, equalTo: Date(), toGranularity: .day) == true {

        item.value = item.value + value

        if item.value >= item.goal {
            if item.complete == false {

                let today = dayData(for: Date(), modelContext: modelContext)
                today.score += item.reward

                Celebrate = today.score
                item.notFloater = true
            }
            item.complete = true
        }

        dayDone = checkDayCompletion(modelContext: modelContext)
    } else {
        item.value = item.value + value
        if item.value >= item.goal {
            if item.complete == false {
                item.complete = true
            }
        }
    }

    if dayDone == false {
        progressFeedback(completed: item.complete && wasComplete == false)
    }



    saveContext(modelContext: modelContext)
    generateNotifications(modelContext: modelContext)

}

func completeHabit(item: listItem, modelContext: ModelContext, Celebrate: inout Int) {

    let wasComplete = item.complete
    var dayDone = false

    if Calendar.current.isDate(item.timestamp, equalTo: Date(), toGranularity: .day) == true {

        if item.complete == false {
            item.value = item.goal
            item.complete = true

            if item.subhabits.isEmpty == false {
                item.subhabitChecked = Array(repeating: true, count: item.subhabits.count)
            }

            let today = dayData(for: Date(), modelContext: modelContext)
            today.score += item.reward

            Celebrate = today.score

            item.notFloater = true
        }

        dayDone = checkDayCompletion(modelContext: modelContext)
    } else {
        if item.complete == false {
            item.value = item.goal
            item.complete = true

            if item.subhabits.isEmpty == false {
                item.subhabitChecked = Array(repeating: true, count: item.subhabits.count)
            }

            item.notFloater = true
        }
    }

    if dayDone == false && wasComplete == false {
        progressFeedback(completed: true)
    }

    saveContext(modelContext: modelContext)
    generateNotifications(modelContext: modelContext)

}

func subValue(item: listItem, value: Int, modelContext: ModelContext, Celebrate: inout Int) {

    if Calendar.current.isDate(item.timestamp, equalTo: Date(), toGranularity: .day) == true {

        if item.value > 0 {
            item.value = item.value - value
        }

        if item.value < item.goal {
            if item.complete == true {

                let today = dayData(for: Date(), modelContext: modelContext)
                today.score -= item.reward

                Celebrate = today.score

            }
            item.complete = false
        }
    } else {
        item.value = item.value - value
        if item.value < item.goal {
            if item.complete == true {
                item.complete = false
            }
        }
    }
    saveContext(modelContext: modelContext)
    generateNotifications(modelContext: modelContext)

}

func setStatus(refItem: listItem, modelContext: ModelContext, updateItemStatus: String) {
    refItem.statusText = updateItemStatus

    saveContext(modelContext: modelContext)

    print(refItem.statusText)
}

// ---------------------------------------------------------------------------------------------------------------------
// CELEBRATION
// ---------------------------------------------------------------------------------------------------------------------

func celebrationProcedure () {
        print("Goal for the day has been completed!")

    // Tier 3 feedback: the day-complete "super buzz" + fanfare
    playCustomHaptic()
    AudioServicesPlaySystemSound(1025) // Fanfare
}

// Fires at most once per calendar day: the latch date means a docket that grows after the goal
// was already met doesn't re-trigger the event. Returns true when it fires, so the caller can
// skip its own (lower-tier) feedback.
func checkDayCompletion(modelContext: ModelContext) -> Bool {
    let today = calendar.startOfDay(for: Date())

    if let last = UserDefaults.standard.object(forKey: "lastCelebrationDay") as? Date,
       calendar.isDate(last, inSameDayAs: today) {
        return false
    }

    let goal = goalFor(date: Date(), modelContext: modelContext)

    // goal == 0 means nothing is on the docket — an empty day isn't a completed one
    guard goal > 0, scoreFor(date: Date(), modelContext: modelContext) >= goal else { return false }

    UserDefaults.standard.set(today, forKey: "lastCelebrationDay")
    celebrationProcedure()
    return true
}

// Tier 1 (progress) and tier 2 (item completed) feedback. System sounds follow the silent
// switch and mix with whatever audio is already playing.
func progressFeedback(completed: Bool) {
    if completed {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1113) // begin_record chime
    } else {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        AudioServicesPlaySystemSound(1104) // keyboard Tock
    }
}

var hapticEngine: CHHapticEngine?

func setupHapticEngine() {
    do {
        hapticEngine = try CHHapticEngine()
        hapticEngine?.playsHapticsOnly = true
        hapticEngine?.isAutoShutdownEnabled = true
        try hapticEngine?.start()
    } catch {
        print("Error creating or starting haptic engine: \(error)")
    }
}

// Day-complete pattern: four rising taps, a long full-strength buzz, then a closing hit (~1.4s).
// A fresh engine is made per play (once a day), so a stopped/reset engine can't swallow it.
func playCustomHaptic() {
    setupHapticEngine()
    guard let engine = hapticEngine else { return }

    func params(_ intensity: Float, _ sharpness: Float) -> [CHHapticEventParameter] {
        [CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
         CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)]
    }

    var events: [CHHapticEvent] = []
    for step in 0..<4 {
        events.append(CHHapticEvent(eventType: .hapticTransient, parameters: params(0.55 + 0.15 * Float(step), 0.8), relativeTime: 0.1 * Double(step)))
    }
    events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: params(1.0, 0.5), relativeTime: 0.45, duration: 0.8))
    events.append(CHHapticEvent(eventType: .hapticTransient, parameters: params(1.0, 1.0), relativeTime: 1.35))

    do {
        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
    } catch {
        print("Error playing haptic pattern: \(error)")
    }
}


// ---------------------------------------------------------------------------------------------------------------------
// GENERATE TEST HABIT DATA
// ---------------------------------------------------------------------------------------------------------------------

// Backfills the past 14 days (excluding today, so the daily checklist isn't disturbed) with one
// randomized item per existing habit, for previewing graphs and testing future features.
func generateTestHabitData (modelContext: ModelContext) {

    do {
        let habitData = try modelContext.fetch(FetchDescriptor<habItem>())

        let todayStart = Calendar.current.startOfDay(for: Date())

        for dayOffset in 1...14 {
            let day = Calendar.current.date(byAdding: .day, value: -dayOffset, to: todayStart) ?? todayStart

            for index in habitData {
                let newItem = listItem(from: index, timestamp: day)

                if index.hasCheckbox {
                    newItem.complete = Bool.random()
                } else {
                    newItem.value = Int.random(in: 0...max(index.goal, 1))
                    newItem.complete = newItem.value >= index.goal
                }

                modelContext.insert(newItem)
            }
        }

    } catch {
        print("Failed fetching habits for test data: \(error)")
        return
    }

    saveContext(modelContext: modelContext)

}

// ---------------------------------------------------------------------------------------------------------------------
// INDEX PROTOCOLS
// ---------------------------------------------------------------------------------------------------------------------

func indexProtocols (modelContext: ModelContext) {

    var habitData: [habItem] = []

    do {
        habitData = try modelContext.fetch(FetchDescriptor<habItem>())
    } catch {}


        if var protocolArray: [HabitProtocol] = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") {
            var slicer: Int = 0
            var ndxInArray: Bool = false
                
                for ndx in protocolArray {
                    print("Iteration \(slicer), protocol is \(ndx.ProtocolName)")
                    ndxInArray = false
                    
                    for ndx2 in habitData {
                        if ndx.ProtocolName == ndx2.whichProtocol {
                            ndxInArray = true
                        }
                    }
                    
                    if ndxInArray == false {
                        print("removing \(ndx.ProtocolName), index is \(slicer)")
                        protocolArray.remove(at: slicer) 
                    } else {slicer += 1}
                    
                }
                

                for ndx in habitData {
                    var inArray = false
                    print("Executing for item ", ndx.name)
                    for ndx2 in protocolArray {
                        if ndx.whichProtocol == ndx2.ProtocolName {
                            inArray = true
                        }
                    }
                    if inArray == false {
                        protocolArray.append(HabitProtocol(ProtocolName: ndx.whichProtocol, ProtocolDescription: ""))
                    }
                }

            UserDefaults.standard.setEncodable(protocolArray, forKey: "protocol")

        } else {
            let pArray: [HabitProtocol] = []
            UserDefaults.standard.setEncodable(pArray, forKey: "protocol")
        }

    }
