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

var closeButton: some View {
    Image(systemName: "x.circle")
        .resizable()
        .foregroundColor(.white)
        .scaledToFit()
        .frame(width: 100,height: 24)
        .bold()
}





let valueRange = 1 ... 1000
let Today: Date = Date()
let calendar: Calendar = .current


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
    
    var HabitUseDow: Bool = false
    
    var HabitOnSun: Bool = false
    var HabitOnMon: Bool = false
    var HabitOnTues: Bool = false
    var HabitOnWed: Bool = false
    var HabitOnThurs: Bool = false
    var HabitOnFri: Bool = false
    var HabitOnSat: Bool = false

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
    
    item.name = (">> " + (item.name ?? ""))
    
    do {
        try viewContext.save()
    } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    
    
}






// ---------------------------------------------------------------------------------------------------------------------
// SET STATUS
// ---------------------------------------------------------------------------------------------------------------------



func setStatus(refItem: Item, viewContext: NSManagedObjectContext, updateItemStatus: Int16) {
    refItem.status = updateItemStatus
    do {
        try viewContext.save()
    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    print(refItem.status)
}


func deleteEntity(withUUID uuid: UUID, viewContext: NSManagedObjectContext) {
    // Create a fetch request for your entity
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
    // Create a fetch request for your entity
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
    // Create a fetch request for your entity
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
    
    
    do {
        try viewContext.save()
        deleteEntityTask(withUUID: taskToShunt.id ?? UUID(), viewContext: viewContext)
    } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
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
}

func displayHabitDescription (identifier: String) -> String {

    for index in UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? [] {
        if index.HabitName == identifier {
            return index.HabitDescription
        }
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


func addOne(item: Item, viewContext: NSManagedObjectContext, Celebrate: inout Int16) {
    
    if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {

        item.value = item.value + 1
        
        if item.value >= item.goal {
            if item.complete == false {
                Celebrate += item.reward
                item.notFloater = true
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

        if item.complete == false {
            item.value = item.goal
            item.complete = true
            Celebrate += item.reward
            item.notFloater = true
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
            var slicer: Int = 0
            var ndxInArray: Bool = false
                
                for ndx in protocolArray {
                    print("Iteration \(slicer), protocol is \(ndx.ProtocolName)")
                    ndxInArray = false
                    
                    for ndx2 in habitData {
                        if ndx.ProtocolName == ndx2.HabitProtocol {
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
                    print("Executing for item ", ndx.HabitName)
                    for ndx2 in protocolArray {
                        if ndx.HabitProtocol == ndx2.ProtocolName {
                            inArray = true
                        }
                    }
                    if inArray == false {
                        protocolArray.append(HabitProtocol(ProtocolName: ndx.HabitProtocol, ProtocolDescription: ""))
                    }
                }

            UserDefaults.standard.setEncodable(protocolArray, forKey: "protocol")

        } else {
            let pArray: [HabitProtocol] = []
            UserDefaults.standard.setEncodable(pArray, forKey: "protocol")
        }
    }
