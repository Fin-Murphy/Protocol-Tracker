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







let valueRange = 1 ... 1000
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
    var TaskHasCheckbox: Bool
    
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

func shuntTask (taskToShunt: Task, viewContext: NSManagedObjectContext) {
    
    let newItem = Item(context: viewContext)
    newItem.timestamp = Date()
    newItem.name = taskToShunt.TaskName
    newItem.goal = taskToShunt.TaskGoal
    newItem.unit = taskToShunt.TaskUnit
    newItem.complete = false
    newItem.reward = taskToShunt.TaskReward
    newItem.isTask = true
    newItem.id = UUID()
    newItem.descriptor = taskToShunt.TaskDescription
    newItem.hasCheckbox = taskToShunt.TaskHasCheckbox
    rmTask(id: taskToShunt.id)
    
    do {
        try viewContext.save()
    } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
}


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



