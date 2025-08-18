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

let valueRange = 1 ... 1000
let Today: Date = Date()
let calendar: Calendar = .current

// ---------------------------------------------------------------------------------------------------------------------
// ITEM STRUCTURES
// ---------------------------------------------------------------------------------------------------------------------

struct HabitProtocol: Identifiable, Codable {
    var id: UUID = UUID()
    var ProtocolName: String
    var ProtocolDescription: String
    var ProtocolContent: [Habit] = []
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


// ---------------------------------------------------------------------------------------------------------------------
// COLOR SCHEME FUNCS
// ---------------------------------------------------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------------------------------------------------
// SCOOT ITEM
// ---------------------------------------------------------------------------------------------------------------------

func scootItem(item: Item, viewContext: NSManagedObjectContext){
    
    let newItem = Item(context: viewContext)
    newItem.timestamp = (calendar.date(byAdding: .day, value: 1, to: Date())!)
    newItem.name = item.name
    newItem.goal = item.goal
    newItem.unit = item.unit
    newItem.whichProtocol = item.whichProtocol
    newItem.complete = false
    newItem.reward = item.reward
    newItem.id = UUID()
    newItem.hasStatus = item.hasStatus
    newItem.hasCheckbox = item.hasCheckbox
    newItem.notFloater = true
    
    item.name = ("> " + (item.name ?? ""))
    
    saveViewContext(viewContext: viewContext)
    
}

// ---------------------------------------------------------------------------------------------------------------------
// DELETE ENTITY FUNCTIONS
// ---------------------------------------------------------------------------------------------------------------------

func deleteEntity(withUUID uuid: UUID, viewContext: NSManagedObjectContext) {

    let request: NSFetchRequest<Item> = Item.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
    request.fetchLimit = 1
    
    do {
        let results = try viewContext.fetch(request)
        if let entityToDelete = results.first {
            viewContext.delete(entityToDelete)
            try viewContext.save()
        }
    } catch {
        print("Error deleting entity: \(error)")
    }
}

func deleteEntityHabit(withUUID uuid: UUID, viewContext: NSManagedObjectContext) {

    let request: NSFetchRequest<HabitItem> = HabitItem.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
    request.fetchLimit = 1
    
    do {
        let results = try viewContext.fetch(request)
        if let entityToDelete = results.first {
            viewContext.delete(entityToDelete)
            try viewContext.save()
        }
    } catch {
        print("Error deleting entity: \(error)")
    }
}

func deleteEntityTask(withUUID uuid: UUID, viewContext: NSManagedObjectContext) {

    let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
    request.fetchLimit = 1
    
    do {
        let results = try viewContext.fetch(request)
        if let entityToDelete = results.first {
            viewContext.delete(entityToDelete)
            try viewContext.save()
        }
    } catch {
        print("Error deleting entity: \(error)")
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// SHUNT TASK FUNCTIONS
// ---------------------------------------------------------------------------------------------------------------------

func shuntTask (taskToShunt: TaskItem, viewContext: NSManagedObjectContext) {
    
    let newItem = Item(context: viewContext)
    newItem.timestamp = Date()
    newItem.name = taskToShunt.name
    newItem.goal = taskToShunt.goal
    newItem.unit = taskToShunt.unit
    newItem.complete = false
    newItem.reward = taskToShunt.reward
    newItem.isTask = true
    newItem.id = UUID()
    newItem.descriptor = taskToShunt.descript
    newItem.hasCheckbox = taskToShunt.hasCheckbox
    newItem.notFloater = taskToShunt.notFloater
    
    saveViewContext(viewContext: viewContext)
    deleteEntityTask(withUUID: taskToShunt.id ?? UUID(), viewContext: viewContext)

}

func shuntTodaysTasks (viewContext: NSManagedObjectContext) {
    do {
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        let taskData = try viewContext.fetch(request)
        
        for index in taskData {
            if (Calendar.current.isDate((index.dueDate ?? Date()), equalTo: Date(), toGranularity: .day) == true) && (index.notFloater == true) {
                shuntTask(taskToShunt: index, viewContext: viewContext)
            }
        }
    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    
    saveViewContext(viewContext: viewContext)

}

// ---------------------------------------------------------------------------------------------------------------------
// UTILITIES
// ---------------------------------------------------------------------------------------------------------------------

func displayHabitDescription (identifier: String, viewContext: NSManagedObjectContext) -> String {
    do {
        let request: NSFetchRequest<HabitItem> = HabitItem.fetchRequest()
        let habitData = try viewContext.fetch(request)
        
        for index in habitData {
            if index.name == identifier {
                return index.descript ?? ""
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

func saveViewContext(viewContext: NSManagedObjectContext){
    
    do {
        try viewContext.save()
    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    
    
}

// ---------------------------------------------------------------------------------------------------------------------
// VALUEMOD FUNCTIONS
// ---------------------------------------------------------------------------------------------------------------------

func addValue(item: Item, value: Int16, viewContext: NSManagedObjectContext, Celebrate: inout Int16){
    if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {

        item.value = item.value + value
        
        if item.value >= item.goal {
            if item.complete == false {
                
                var TodayScore = UserDefaults.standard.integer(forKey: "TodayScore")
                TodayScore += Int(item.reward)
                UserDefaults.standard.set(TodayScore, forKey: "TodayScore")
                
                Celebrate = Int16(TodayScore)
                item.notFloater = true
            }
            item.complete = true
        }
        
        if Celebrate >= UserDefaults.standard.integer(forKey: "dailyGoal") {
            celebrationProcedure()
        }
    } else {
        item.value = item.value + value
        if item.value >= item.goal {
            if item.complete == false {
                item.complete = true
            }
        }
    }
    
    
    
    saveViewContext(viewContext: viewContext)
}

func completeHabit(item: Item, viewContext: NSManagedObjectContext, Celebrate: inout Int16) {
    
    if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {

        if item.complete == false {
            item.value = item.goal
            item.complete = true
            
            var TodayScore = UserDefaults.standard.integer(forKey: "TodayScore")
            TodayScore += Int(item.reward)
            UserDefaults.standard.set(TodayScore, forKey: "TodayScore")
            
            Celebrate = Int16(TodayScore)
            
            item.notFloater = true
        }
        
        if Celebrate >= UserDefaults.standard.integer(forKey: "dailyGoal") {
            celebrationProcedure()
        }
    } else {
        if item.complete == false {
            item.value = item.goal
            item.complete = true
            item.notFloater = true
        }
    }
      
    saveViewContext(viewContext: viewContext)
}

func subValue(item: Item, value: Int16, viewContext: NSManagedObjectContext, Celebrate: inout Int16) {
    
    if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {
        
        if item.value > 0 {
            item.value = item.value - value
        }
        
        if item.value < item.goal {
            if item.complete == true {
                
                var TodayScore = UserDefaults.standard.integer(forKey: "TodayScore")
                TodayScore -= Int(item.reward)
                UserDefaults.standard.set(TodayScore, forKey: "TodayScore")
                
                Celebrate = Int16(TodayScore)
                
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
    saveViewContext(viewContext: viewContext)
}

func setStatus(refItem: Item, viewContext: NSManagedObjectContext, updateItemStatus: Int16) {
    refItem.status = updateItemStatus

    saveViewContext(viewContext: viewContext)
    
    print(refItem.status)
}

// ---------------------------------------------------------------------------------------------------------------------
// CELEBRATION
// ---------------------------------------------------------------------------------------------------------------------

func celebrationProcedure () {
        print("Goal for the day has been completed!")
}

// ---------------------------------------------------------------------------------------------------------------------
// INDEX PROTOCOLS
// ---------------------------------------------------------------------------------------------------------------------

func indexProtocols (viewContext: NSManagedObjectContext) {
    
    var habitData: [HabitItem] = []
    
    do {
        let request: NSFetchRequest<HabitItem> = HabitItem.fetchRequest()
        habitData = try viewContext.fetch(request)
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
                    print("Executing for item ", ndx.name ?? "")
                    for ndx2 in protocolArray {
                        if ndx.whichProtocol == ndx2.ProtocolName {
                            inArray = true
                        }
                    }
                    if inArray == false {
                        protocolArray.append(HabitProtocol(ProtocolName: ndx.whichProtocol ?? "", ProtocolDescription: ""))
                    }
                }

            UserDefaults.standard.setEncodable(protocolArray, forKey: "protocol")

        } else {
            let pArray: [HabitProtocol] = []
            UserDefaults.standard.setEncodable(pArray, forKey: "protocol")
        }
    
        saveViewContext(viewContext: viewContext)

    }
