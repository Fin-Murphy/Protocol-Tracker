//
//  Globals.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/21/25.
//

import Foundation
import CoreData
import SwiftUI


 //------------------------------------------------------

//                    DATA STRUCTURES

//------------------------------------------------------


class GlobalVars {
    static let shared = GlobalVars()
    private init() {}
    
    
} // END CLASS GlobalVars

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                       to: nil, from: nil, for: nil)
    }
}







let valueRange = 1 ... 100
let Today: Date = Date()
let calendar: Calendar = .current


struct HabitProtocol: Identifiable, Codable {
    var id: UUID = UUID()
    var ProtocolName: String
}


struct Task: Identifiable, Codable {
    
    var id: UUID = UUID()
    var TaskName: String
    var TaskDescription: String
    var TaskReward: Int16
    var TaskDueDate: Date = Date()
    var TaskUnit: String
    var TaskGoal: Int16
    
}


struct Habit: Identifiable, Codable {
    
    var id: UUID = UUID()
    var HabitName:String
    var HabitValue:Int16
    var HabitGoal:Int16
    var HabitUnit:String
    var HabitProtocol:String
    var HabitStartDate: Date = Date()
    var HabitRepeatValue: Int = 1
    var HabitDescription: String
    var HabitReward: Int16
    var HabitHasStatus: Bool
} // END struct Task


var forward_Calendar = valueRange.map {
    calendar.date(byAdding: .day, value: $0, to: Today)!
}

var backward_Calendar = valueRange.map {
    calendar.date(byAdding: .day, value: -$0, to: Today)!
}





//------------------------------------------------------

//                    FUNCTIONS

//------------------------------------------------------


let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()


func daysBetween(start: Date, end: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: start, to: end)
    return components.day ?? 0
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



func rmHabit(id: UUID) {
    if var outHabitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") {
        var iterator = 0
        for index in outHabitData {
            if index.id == id {
                outHabitData.remove(at: iterator)
            }
            iterator += 1
        }
        UserDefaults.standard.setEncodable(outHabitData, forKey: "habitList")
    }
}


func rmTask(id: UUID) {
    if var outTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") {
        var iterator = 0
        for index in outTaskData {
            if index.id == id {
                outTaskData.remove(at: iterator)
            }
            iterator += 1
        }
        UserDefaults.standard.setEncodable(outTaskData, forKey: "taskList")
    }
}



