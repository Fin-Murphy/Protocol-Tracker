//
//  Datum.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/11/26.
//

import Foundation
import SwiftData

@Model
class dow {
    
    init(onSun: Bool, onMon: Bool, onTues: Bool, onWed: Bool, onThurs: Bool,  onFri: Bool, onSat: Bool) {
        self.onFri = onFri
        self.onMon = onMon
        self.onSat = onSat
        self.onSun = onSun
        self.onThurs = onThurs
        self.onTues = onTues
        self.onWed = onWed
    }
    
    var onFri: Bool = false
    var onMon: Bool = false
    var onSat: Bool = false
    var onSun: Bool = false
    var onThurs: Bool = false
    var onTues: Bool = false
    var onWed: Bool = false

}

@Model
class habItem { // Wow, thats a lot of data fields! Time to use sum inheritance
    
    init(descript: String, goal: Int, hasCheckbox: Bool, hasStatus: Bool, hasSubtask: Bool, id: UUID, isSubtask: Bool, name: String, order: Int, repeatValue: Int, reward: Int, startDate: Date, superTask: UUID? = nil, timeRegion: String, unit: String, useDow: Bool, whichProtocol: String) {

        self.dow = .init(onSun: false, onMon: false, onTues: false, onWed: false, onThurs: false, onFri: false, onSat: false)

        self.descript = descript
        self.goal = goal
        self.hasCheckbox = hasCheckbox
        self.hasStatus = hasStatus
        self.hasSubtask = hasSubtask
        self.id = id
        self.isSubtask = isSubtask
        self.name = name
        self.order = order
        self.repeatValue = repeatValue
        self.reward = reward
        self.startDate = startDate
        self.timeRegion = timeRegion
        self.unit = unit
        self.useDow = useDow
        self.whichProtocol = whichProtocol
    }
    
    var dow: dow

    var descript: String = ""
    var goal: Int = 1
    var hasCheckbox: Bool = false
    var hasStatus: Bool = false
    var hasSubtask: Bool = false
    var id: UUID = UUID()
    var isSubtask: Bool = false
    var name: String = "Habit"

    var order: Int = 0
    var repeatValue: Int = 1
    var reward: Int = 1
    var startDate: Date = Date()
    var timeRegion: String = "None"
    var unit: String = "Units"
    var useDow: Bool = false
    var whichProtocol: String = "Daily"
}

@Model
class listItem { // A concrete instance on a specific day's checklist, spawned from habits or shunted from tasks

    init(complete: Bool, descriptor: String, goal: Int, hasCheckbox: Bool, hasStatus: Bool, id: UUID, isTask: Bool, name: String, notFloater: Bool, reward: Int, statusText: String, timeRegion: String, timestamp: Date, unit: String, value: Int, whichProtocol: String) {

        self.complete = complete
        self.descriptor = descriptor
        self.goal = goal
        self.hasCheckbox = hasCheckbox
        self.hasStatus = hasStatus
        self.id = id
        self.isTask = isTask
        self.name = name
        self.notFloater = notFloater
        self.reward = reward
        self.statusText = statusText
        self.timeRegion = timeRegion
        self.timestamp = timestamp
        self.unit = unit
        self.value = value
        self.whichProtocol = whichProtocol
    }

    var complete: Bool = false
    var descriptor: String = ""
    var goal: Int = 1
    var hasCheckbox: Bool = false
    var hasStatus: Bool = false
    var id: UUID = UUID()
    var isTask: Bool = false
    var name: String = ""
    var notFloater: Bool = true
    var reward: Int = 1
    var statusText: String = ""
    var timeRegion: String = "None"
    var timestamp: Date = Date()
    var unit: String = "Units"
    var value: Int = 0
    var whichProtocol: String = "Daily"
}

extension listItem {
    // Spawns a fresh checklist instance from a habit template for the given day
    convenience init(from habit: habItem, timestamp: Date) {
        self.init(complete: false,
                  descriptor: "",
                  goal: habit.goal,
                  hasCheckbox: habit.hasCheckbox,
                  hasStatus: habit.hasStatus,
                  id: UUID(),
                  isTask: false,
                  name: habit.name,
                  notFloater: true,
                  reward: habit.reward,
                  statusText: "",
                  timeRegion: habit.timeRegion,
                  timestamp: timestamp,
                  unit: habit.unit,
                  value: 0,
                  whichProtocol: habit.whichProtocol)
    }
}

@Model
class taskItem { // A one-off task with a due date, waiting to be shunted into the checklist

    init(descript: String, dueDate: Date, goal: Int, hasCheckbox: Bool, id: UUID, name: String, notFloater: Bool, reward: Int, unit: String) {

        self.descript = descript
        self.dueDate = dueDate
        self.goal = goal
        self.hasCheckbox = hasCheckbox
        self.id = id
        self.name = name
        self.notFloater = notFloater
        self.reward = reward
        self.unit = unit
    }

    var descript: String = ""
    var dueDate: Date = Date()
    var goal: Int = 1
    var hasCheckbox: Bool = true
    var id: UUID = UUID()
    var name: String = "Task"
    var notFloater: Bool = true
    var reward: Int = 1
    var unit: String = "units"
}

@Model
class dayScore { // One record per calendar day holding that day's accumulated points

    init(day: Date, score: Int) {
        self.day = day
        self.score = score
    }

    var day: Date = Date()
    var score: Int = 0
}
