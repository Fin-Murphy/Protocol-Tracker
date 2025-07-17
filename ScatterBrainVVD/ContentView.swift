//
//  ContentView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/20/25.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @Environment(\.scenePhase) private var scenePhase
        
    @State var selectedTab: Tabs = .HUB
    
    @State var SelectedDate: Date = Date()
    
    let calendar = Calendar(identifier: .gregorian)
    
    @State var moveCompleteHabits: Bool = false
    
    @State var Celebrate: Int16 = 0
    
    @State var updateItemStatus: Int16 = 0
    
    @State var habitData: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
    
    @State var seenWelcome: Bool = !UserDefaults.standard.bool(forKey: "seenWelcome")
    
    //-------------------------------------------
    @State var range:Int = 4
    //----------------------------------------------------------
    
    @Environment(\.managedObjectContext) public var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
//    @State var passDownItems: [Item] = []
    

    var body: some View {
    
       VStack{
    
/* *******************************************************
                Calendar TAB
 ****************************************************** */
    
           if selectedTab == .Calendar {
               
               
               CalendarView(SelectedDate: $SelectedDate, selectedTab: $selectedTab)
                
               
/* *******************************************************
                       BOOK TAB
****************************************************** */
                
            } else if selectedTab == .Settings {
                                    
                GoalSetView()
             
/* *******************************************************
             MONEY TAB
******************************************************** */
         }
            else if selectedTab == .Protocols {
                                    
                HabitBuilderView(viewContext: _viewContext)
                    
                
/* *******************************************************
            GOALS TAB
****************************************************** */
            } else if selectedTab == .Goals {
                
                TaskBuilderView(context: _viewContext, selectedTab: $selectedTab)
                
/* *******************************************************
            MAIN TASK TAB
****************************************************** */
            
                
            } else if selectedTab == .HUB {
                
                // TOP DATE BAR ---------------------------------------------------------------------
                
                // TOP DATE BAR ---------------------------------------------------------------------
    
                
                MainListTab(
                    selectedTab: $selectedTab,
                    Celebrate: $Celebrate,
                    SelectedDate: $SelectedDate,
                    moveCompleteHabits: $moveCompleteHabits
                )
                
            }// END HUB TAB
            
            Spacer()
                        
            TabBar(selectedTab: $selectedTab)
       }
       .onAppear{refreshVisualData(ForeColor: &ForeColor)}
       .onChange(of: scenePhase) {newval in
               refreshVisualData(ForeColor: &ForeColor)
       }
    }

/*    ------------------------------------------------
                   BEGIN PRIVATE FUNCTIONS
     ------------------------------------------------     */


    
    /*    ------------------------------------------------
                    DESHUNT TASKS
     ------------------------------------------------     */
    
    private func deshuntTask(item: Item) {
//        print("Running deshunt for item \(item.name ?? "")")
        if item.isTask == true {
//            print("Successful!")
            let returnedTask = Task(id: UUID(),
                                    TaskName: item.name ?? "",
                                    TaskDescription: item.descriptor ?? "",
                                    TaskReward: item.reward,
                                    TaskDueDate: (calendar.date(byAdding: .day, value: 1, to: Date())!),
                                    TaskUnit: item.unit ?? "",
                                    TaskGoal: item.goal,
                                    TaskHasCheckbox: item.hasCheckbox,
                                    TaskNotFloater: item.notFloater)
            
            if var outTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") {
                outTaskData.append(returnedTask)
                UserDefaults.standard.setEncodable(outTaskData, forKey: "taskList")
            } else {
                let taskDataInitialzier: [Task] = [returnedTask]
                UserDefaults.standard.setEncodable(taskDataInitialzier, forKey: "taskList")
            }
            deleteEntity(withUUID: item.id ?? UUID())
            
        } else {}
        
    }
    
    /* ------------------------------------------------
                    DELETE ENTITY
     ------------------------------------------------     */
    
    
    private func deleteEntity(withUUID uuid: UUID) {
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
    } //END FUNC DELETE ENTITY
    
    /* ------------------------------------------------
                    SET STATUS
     ------------------------------------------------     */
    
    private func setStatus(refItem: Item) {
        refItem.status = updateItemStatus
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        print(refItem.status)
    }
    

    
    
    /*    ------------------------------------------------
                    CHECK DATE
     ------------------------------------------------     */
    
    public func checkDate() {
        if let savedDate = UserDefaults.standard.object(forKey: "DailyTaskPopulate?") as? Date {
            
            let comparison = calendar.compare(Date(), to: savedDate, toGranularity: .day)

            if comparison == .orderedDescending {
                populateTasks()
                UserDefaults.standard.set(Date(), forKey: "DailyTaskPopulate?")
                Celebrate = 0
                SelectedDate = Date()
            } else {}
            
        } else {
            UserDefaults.standard.set(Date(), forKey: "DailyTaskPopulate?")
            populateTasks()
        }
    }




    /*    ------------------------------------------------
                   POPULATE TASKS
     ------------------------------------------------     */
    private func populateTasks() {
        
        habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
        
        for taskFinder in items {
            if Calendar.current.isDate((taskFinder.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) != true {
                if taskFinder.complete == false {
                    deshuntTask(item: taskFinder)
                }
            } else {}
        }
        
        checkTaskDueDates(viewContext: viewContext)
        
        for index in habitData {
            print("\(index.HabitName) - \(daysBetween(start: index.HabitStartDate,end: Calendar.current.startOfDay(for: Date())))")
        }

        for index in habitData {
            
            
            if (daysBetween(start: Calendar.current.startOfDay(for: index.HabitStartDate),end: Calendar.current.startOfDay(for: Date())) >= 0) && (daysBetween(start:  Calendar.current.startOfDay(for: index.HabitStartDate),end: Calendar.current.startOfDay(for: Date())) % index.HabitRepeatValue == 0) {
                                        
                let newItem = Item(context: viewContext)
                newItem.timestamp = Date()
                newItem.name = index.HabitName
                newItem.goal = index.HabitGoal
                newItem.unit = index.HabitUnit
                newItem.whichProtocol = index.HabitProtocol
                newItem.complete = false
                newItem.reward = index.HabitReward
                newItem.id = UUID()
                newItem.hasStatus = index.HabitHasStatus
                newItem.hasCheckbox = index.HabitHasCheckbox
    
            }
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    

    /*    ------------------------------------------------
                   DELETE ITEM
     ------------------------------------------------     */
    
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
    
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
