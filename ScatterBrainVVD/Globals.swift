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

func refreshVisualData(ForeColor:  inout Color) {
    currentScheme = getCurrentColorScheme()
    ForeColor = currentScheme == .dark ? .white : .black
}

func getCurrentColorScheme() -> ColorScheme {
    let traitCollection = UITraitCollection.current
    return traitCollection.userInterfaceStyle == .dark ? .dark : .light
}

var currentScheme = getCurrentColorScheme()
var ForeColor: Color = currentScheme == .dark ? .white : .black

//let ForeColor: Color = Color.black


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
    var HabitIsSubtask: Bool = false
    var HabitHasSubtask: Bool = false
    var HabitSuperTask: UUID?

} // END struct Task


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


struct backgroundMod: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(ForeColor, lineWidth: 3)
            )
            .cornerRadius(10)
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


func checkTaskDueDates (viewContext: NSManagedObjectContext) {
    
    if let outTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") {
        for index in outTaskData {
            if Calendar.current.isDate((index.TaskDueDate), equalTo: Date(), toGranularity: .day) == true {
                shuntTask(taskToShunt: index, viewContext: viewContext)
            }
        }
    } else {
        print("Failure for task due date checker")
    }
    
}


func displayHabitDescription (identifier: String) -> String {

    for index in UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? [] {
        if index.HabitName == identifier {
            return index.HabitDescription
        }
    }
    return "No description"
}

func resetUserDefaults () {
    UserDefaults.standard.removeObject(forKey: "DailyTaskPopulate?")
    
//        UserDefaults.standard.removeObject(forKey: "habitList")
//        UserDefaults.standard.removeObject(forKey: "protocol")
//
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


func addOne(item: Item, viewContext: NSManagedObjectContext, Celebrate: inout Int16) {
    
    if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {

        item.value = item.value + 1
        
        if item.value >= item.goal {
            if item.complete == false {
                Celebrate += item.reward
            }
            item.complete = true
        }
        
        if Celebrate >= UserDefaults.standard.integer(forKey: "dailyGoal") {
            celebrationProcedure()
        }
    }
        

 
    do {
        try viewContext.save()
    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
}

func completeHabit(item: Item, viewContext: NSManagedObjectContext, Celebrate: inout Int16) {
    
    if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {

        item.value = item.goal
        item.complete = true
        Celebrate += item.reward
        
        if Celebrate >= UserDefaults.standard.integer(forKey: "dailyGoal") {
            celebrationProcedure()
        }
    }
      
    do {
        try viewContext.save()
    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    
    
}


func subOne(item: Item, viewContext: NSManagedObjectContext, Celebrate: inout Int16) {
    
    if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {
        
        if item.value > 0 {
            item.value = item.value - 1
        }
        
        if item.value < item.goal {
            if item.complete == true {
                Celebrate -= item.reward
            }
            item.complete = false
        }
    }
    
    do {
        try viewContext.save()
    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
}



func celebrationProcedure () {
        print("Goal for the day has been completed!")
}

func indexProtocols () {
    
    let habitData: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []


        if var protocolArray: [HabitProtocol] = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") {

                for ndx in habitData {
                    var inArray = false
                    print("Executing for item ", ndx.HabitName)
                    for ndx2 in protocolArray {
                        if ndx.HabitProtocol == ndx2.ProtocolName {
                            inArray = true
                        }
                    }
                    if inArray == false {
                        protocolArray.append(HabitProtocol(ProtocolName: ndx.HabitProtocol))
                    }
                }

            UserDefaults.standard.setEncodable(protocolArray, forKey: "protocol")

        } else {
            let pArray: [HabitProtocol] = [/*TaskProtocol(ProtocolName: "Daily")*/]
            UserDefaults.standard.setEncodable(pArray, forKey: "protocol")
        }
    }
