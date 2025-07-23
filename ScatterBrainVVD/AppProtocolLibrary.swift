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
        ProtocolContent:[
            
            Habit(id: UUID(),
                  HabitName: "Sunlight Exposure",
                  HabitGoal: 10,
                  HabitUnit: "Minutes",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "Getting sunlight <FILL THIS OUT>",
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
