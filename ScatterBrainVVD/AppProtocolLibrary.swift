//
//  AppProtocolLibrary.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/22/25.
//

import Foundation
import CoreData
import SwiftUI


//
//struct Task: Identifiable, Codable {
//    
//    var id: UUID = UUID()
//    var TaskName: String
//    var TaskDescription: String
//    var TaskReward: Int16
//    var TaskDueDate: Date = Date()
//    var TaskUnit: String
//    var TaskGoal: Int16
//    var TaskHasCheckbox: Bool
//    var TaskNotFloater: Bool = true
//}
//
//
//struct Habit: Identifiable, Codable, Hashable {
//    
//    var id: UUID = UUID()
//    var HabitName:String
//    var HabitGoal:Int16
//    var HabitUnit:String
//    var HabitProtocol:String
//    var HabitStartDate: Date = Date()
//    var HabitRepeatValue: Int = 1
//    var HabitDescription: String
//    var HabitReward: Int16
//    var HabitHasStatus: Bool
//    var HabitHasCheckbox: Bool
//    var HabitIsSubtask: Bool = false
//    var HabitHasSubtask: Bool = false
//    var HabitSuperTask: UUID?
//
//} // END struct Task



let AppDefinedProtocolLibrary: [HabitProtocol] = [
    HabitProtocol(
        id: UUID(),
        ProtocolName: "Huberman Daily",
        ProtocolDescription: "This Protocol is takend directly from the \"Andrew's Routine\" protocol from the Huberman Lab website as of 7/23/25.",
        ProtocolContent:[
            
            Habit(id: UUID(),
                  HabitName: "Morning Walk/ Sunlight Exposure",
                  HabitGoal: 10,
                  HabitUnit: "Minutes",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "Prioritize light exposure each morning\n • Outdoor light exposure causes a beneficial cortisol peak early in the morning; increases daytime mood, energy and alertness; and helps you fall asleep more easily at night. \n A morning walk outdoors can provide you with both light exposure and optic flow, which quiets activity of the amygdala and related circuits and reduces feelings of stress and anxiety all day.",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: false,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil),
            Habit(id: UUID(),
                  HabitName: "Delay Caffeine Intake",
                  HabitGoal: 1,
                  HabitUnit: "units",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "• Delay your caffeine intake by 90-120 minutes after waking to help increase alertness and avoid an afternoon crash. (As a caveat: if exercising first thing in the morning, feel free to drink caffeine before exercise.)",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: true,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil),
            Habit(id: UUID(),
                  HabitName: "Prioritize Hydration",
                  HabitGoal: 1,
                  HabitUnit: "liter",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "Aim to drink around 32 ounces (1 liter) of water during the early morning, and add a pinch of sea salt for a source of electrolytes.",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: false,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil),
            
            
            Habit(id: UUID(),
                  HabitName: "Cold Exposure",
                  HabitGoal: 10,
                  HabitUnit: "Minutes",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "Cold exposure increases dopamine <FILL THIS OUT>",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: false,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil)
        ]
    )
]


