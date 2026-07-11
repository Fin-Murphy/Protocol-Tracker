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
    
    init(goal: Int, hasCheckbox: Bool, hasStatus: Bool, hasSubtask: Bool, id: UUID, isSubtask: Bool, name: String, order: Int, repeatValue: Int, reward: Int, startDate: Date, superTask: UUID? = nil, timeRegion: String, unit: String, useDow: Bool, whichProtocol: String) {
        
        self.dow = .init(onSun: false, onMon: false, onTues: false, onWed: false, onThurs: false, onFri: false, onSat: false)
        
        self.goal = goal
        self.hasCheckbox = hasCheckbox
        self.hasStatus = hasStatus
        self.hasSubtask = hasSubtask
        self.id = id
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
    
    var goal: Int = 1
    var hasCheckbox: Bool = false
    var hasStatus: Bool = false
    var hasSubtask: Bool = false
    var id: UUID = UUID()
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



