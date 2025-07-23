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
                  HabitDescription: "Prioritize light exposure each morning\n • Outdoor light exposure causes a beneficial cortisol peak early in the morning; increases daytime mood, energy and alertness; and helps you fall asleep more easily at night. \n A morning walk outdoors can provide you with both light exposure and optic flow, which quiets activity of the amygdala and related circuits and reduces feelings of stress and anxiety all day. \n How much light you should get depends on the weather conditions - \n ợ: Sunny day = 5-10 mins \n * Cloudy day = 10-15 min \n• Overcast day = up to 30 mins",
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
                  HabitName: "Excercise",
                  HabitGoal: 1,
                  HabitUnit: "units",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "Use exercise to optimize your energy levels\n• Exercise helps to regulate blood sugar, balance hormone levels, improve immunity, and depending on the type of exercise, can either increase energy levels or support feelings of relaxation.",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: true,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil),
            Habit(id: UUID(),
                  HabitName: "Optimize Lunch Food/Hydration",
                  HabitGoal: 1,
                  HabitUnit: "units",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "Optimize your food and hydration\n• Eat a lower-carb lunch to help avoid an afternoon crash.\n• Go for a short 5-30 minute walk after lunch to increase metabolism and further calibrate your circadian rhythm with light exposure.",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: true,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil),
            Habit(id: UUID(),
                  HabitName: "Optimize Dinner Food/Hydration",
                  HabitGoal: 1,
                  HabitUnit: "units",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "• Eat dinner with some higher-carbohydrate (i.e. starchy but still complex) foods and protein to promote relaxation and sleep.",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: true,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil),
            Habit(id: UUID(),
                  HabitName: "Evening light exposure",
                  HabitGoal: 10,
                  HabitUnit: "Minutes",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "• Get light exposure around sunset to reduce the negative effects of light exposure later in the night.",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: false,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil),
            Habit(id: UUID(),
                  HabitName: "Sleep schedule",
                  HabitGoal: 1,
                  HabitUnit: "units",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "• It is crucial to wake up at the same time (+/- 1 hour) each morning, days off included.\n • Sleeping in later than that on the weekend is likely going to disrupt your circadian rhythm and make waking on your regular schedule that much harder.",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: true,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil),
            Habit(id: UUID(),
                  HabitName: "Optimize Sleep Environment",
                  HabitGoal: 1,
                  HabitUnit: "units",
                  HabitProtocol: "Huberman Daily",
                  HabitStartDate: Date(),
                  HabitRepeatValue: 1,
                  HabitDescription: "• Start dimming the lights shortly after sunset and avoid overhead and bright lights in general.\n • Dim computer and phone screens as much as possible, or use a red-hued filter to reduce blue light exposure.\n • Cool your bedroom to 1-3 degrees lower than usual.\n • Make your room as dark as possible using blackout blinds or an eye mask.\n",
                  HabitReward: 1,
                  HabitHasStatus: false,
                  HabitHasCheckbox: true,
                  HabitIsSubtask: false,
                  HabitHasSubtask: false,
                  HabitSuperTask: nil)

        ]
    )
]


