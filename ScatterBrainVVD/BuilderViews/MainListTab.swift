//
//  MainListTab.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/16/25.
//

import SwiftUI
import CoreData

struct navLinkLabel: View {
    
    @ObservedObject var item: Item
    
    var body: some View {
        
        HStack{
            
            if item.isTask == true {
                Image(systemName: "t.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20,height: 20)
            } else {
                Image(systemName: "h.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20,height: 20)
            }
            
            if item.complete == true {
                Text(String(item.name ?? ""))
                    .strikethrough()
                    .foregroundColor(.green)
            } else {
                Text(String(item.name ?? ""))
            }
            Spacer()
            
            if item.complete == true {
                Text("☑")
            } else {
                Text("☐")
            }
            
            if item.hasCheckbox == false {
                Text("\(item.value)/\(item.goal)")
                Text("   ")
            }
        }
        
        
        
    }
}

struct navLinkContent: View {
    
    @Binding var forceUpdate: Bool
    
    @ObservedObject var item: Item

    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext

    @State var updateItemStatus: Int16 = 0

    @State var Celebrate: Int16
    
    var body: some View {
        
        if item.complete == true {
            Text(String(item.name ?? ""))
                .font(.title)
                .fontWeight(.bold)
                .strikethrough()
        } else {
            Text(String(item.name ?? ""))
                .font(.title)
                .fontWeight(.bold)
        }
        
        if item.hasStatus == true {
            
            
            VStack {
                HStack {
                    Text("Habit status:")
                    
                    TextField("", value: $updateItemStatus, format: .number)
                        .frame(maxWidth: 100, alignment: .center)
                }
                .bckMod()
                
                Button {setStatus(refItem: item, viewContext: viewContext, updateItemStatus: updateItemStatus)} label: {
                    Text("Save Habit Status")
                    
                }
                .foregroundColor(.blue)
                .bckMod()
                
            }
            .onAppear{updateItemStatus = item.status}
            .bckMod()
            
            
        } else {}
        
        Spacer()
        
        ScrollView {
            if item.isTask != true {
                if displayHabitDescription(identifier: item.name ?? "") != "" {
                    Text(displayHabitDescription(identifier: item.name ?? ""))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .bckMod()
                }
                
            } else {
                
                Text(item.descriptor ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .bckMod()
            }
            
            
        }.frame(width: 350)
        
        Spacer()
        
        // ---------------------- BEGIN VALUE MODIFICATION
        
        if item.hasCheckbox == false {
            
            if item.complete == true {
                Text("☑ \(item.value)/\(item.goal) \(item.unit ?? "")")
                    .font(.title)
                    .padding()
                    .bckMod()
                
            } else {
                Text("☐ \(item.value)/\(item.goal) \(item.unit ?? "")")
                    .font(.title)
                    .padding()
                    .bckMod()
                
            }
            
            HStack{
                
                Button {
                    addOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                    forceUpdate.toggle()
                    if item.value == item.goal {
                        
                    }
                }
                label: {
                    Text("+ 1")
                        .bckMod()
                }
                Button {
                    subOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                    forceUpdate.toggle()
                    if item.value == item.goal {
                        
                    }
                }
                label: {
                    Text("- 1")
                        .bckMod()
                }
            }
            
        } else {
            
            
            if item.complete == true {
                Button{
                    subOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                    forceUpdate.toggle()
                } label: {
                    Text("☑")
                        .font(.title)
                        .padding()
                        .bckMod()
                }
                
            } else {
                Button{
                    addOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                    forceUpdate.toggle()
                } label: {
                    Text("☐")
                        .font(.title)
                        .padding()
                        .bckMod()
                }
            }
        }
        
        if item.notFloater == true && item.complete == false {
            
            Button {
                scootItem(item: item, viewContext: viewContext)
            } label: {
                Text("Move this item to tomorrow?")
            }
        }
        // ---------------------- END VALUE MODIFICATION
        
        
        Spacer()
        
    }
    
}

struct MainListTab: View {
    
    
    // ---------------------------------------------------------------------------------------------------------------------
    // BINDINGS
    // ---------------------------------------------------------------------------------------------------------------------

    @Binding var selectedTab: Tabs
        
    @Binding var Celebrate: Int16
    
    @Binding var SelectedDate: Date
    
    // ---------------------------------------------------------------------------------------------------------------------
    // STATES
    // ---------------------------------------------------------------------------------------------------------------------

    @State var updateItemStatus: Int16 = 0

    @State var seenWelcome: Bool = !UserDefaults.standard.bool(forKey: "seenWelcome")  // MAKE BINDING
    
    @State var forceUpdate: Bool = false
    
    // ---------------------------------------------------------------------------------------------------------------------
    // COREDATA
    // ---------------------------------------------------------------------------------------------------------------------

    
    @Environment(\.managedObjectContext) public var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
        
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.name, ascending: true)],
        animation: .default)
    private var habitData: FetchedResults<HabitItem>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.name, ascending: true)],
        animation: .default)
    private var taskData: FetchedResults<TaskItem>
    
    // ---------------------------------------------------------------------------------------------------------------------
    // WELCOME MESSAGE
    // ---------------------------------------------------------------------------------------------------------------------

    private var welcomeMessageView: some View {
    
        VStack{
            Text("Welcome to Protocol Tracker!")
            Text("")
            Text("This app is still under heavy development.")
            Text("If you have any issues or encounter any bugs or errors, please let me know!")
            
            
            Text("")
            Text("The 5 tabs along the bottom of the screen are, in this order, the Calendar tab, the Habit Tab, the Main tab, the Task tab, and the Settings tab.")
            Text("The final version of this app aims to replicate all the functionalities of Org mode in a user-friendly format. If you have suggestions, again please let me know!")
            
            Button{
                UserDefaults.standard.set(true, forKey: "seenWelcome")
                seenWelcome = false
            } label: {
                Text("Get Started")
            }
            
        }.bckMod()
    }//END WELCOMEMESSAGEVIEW

    
    
    
    
    
    // ---------------------------------------------------------------------------------------------------------------------
    // BODY CONTENT
    // ---------------------------------------------------------------------------------------------------------------------
    
    var body: some View {
         
        VStack{
            
            DateBarView(SelectedDate: $SelectedDate, Celebrate: $Celebrate)
            
            ZStack{
                
                NavigationView {
                    
                    VStack{
                        
                        List {
                                ForEach(items) { item in
                                    if (Calendar.current.isDate((item.timestamp ?? Date()), equalTo: SelectedDate, toGranularity: .day) == true && item.complete == false) || (item.notFloater == false && item.complete == false) {
                                        
                                        NavigationLink {
                                            
                                            
                                            navLinkContent(forceUpdate: $forceUpdate, item: item, viewContext: _viewContext, Celebrate: Celebrate)
                                            
                                        } label: {
                                            navLinkLabel(item: item)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button("Complete") {
                                                completeHabit(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                                impactFeedback.impactOccurred()
                                            }
                                            .tint(.blue)
                                            
                                        }
                                        .swipeActions(edge: .leading) {
                                            Button("Delete") {
                                                deleteEntity(withUUID: item.id ?? UUID(), viewContext: viewContext)
                                            }
                                            .tint(.red)
                                        }
                                        
                                        
                                    } else {}
                                    
                                }
                                
                                ForEach(items) { item in
                                    
                                    if (Calendar.current.isDate((item.timestamp ?? Date()), equalTo: SelectedDate, toGranularity: .day) == true && item.complete == true)  || (item.notFloater == false && item.complete == true) {
                                        
                                        NavigationLink {
                                            
                                            navLinkContent(forceUpdate: $forceUpdate, item: item, viewContext: _viewContext, Celebrate: Celebrate)
                                            
                                        } // End of navigation link
                                        label: {
                                            
                                            navLinkLabel(item: item)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button("Complete") {
                                                completeHabit(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                                impactFeedback.impactOccurred()
                                            }
                                            .tint(.blue)
                                            
                                        }
                                        .swipeActions(edge: .leading) {
                                            Button("Delete") {
                                                deleteEntity(withUUID: item.id ?? UUID(), viewContext: viewContext)
                                            }
                                            .tint(.red)
                                        }
                                    } else {}
                                }
                            
                        }//END LIST
                        
                        .onAppear{
                            testTasksForSillyness() 
                        }
       
                    }//END VSTACK
                    
                }//END NAV VIEW
                
                if seenWelcome {
                    
                    welcomeMessageView
                
                }
                
                
            }.onAppear{
                checkDate()
            } // END ZSTACK
            
        }//END VSTACK
        
    } // END VIEWABLE CONTENT
    
    // ---------------------------------------------------------------------------------------------------------------------
    
    // START PRIVATE FUNCTIONS
    
    // ---------------------------------------------------------------------------------------------------------------------


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
    

    // ---------------------------------------------------------------------------------------------------------------------
    // POPULATE TASKS
    // ---------------------------------------------------------------------------------------------------------------------

    private func testTasksForSillyness() {
        for taskFinder in items {
            if taskFinder.notFloater == false {
                taskFinder.timestamp = Date()
            }
        }
    }
    
    
    private func populateTasks() {
        
        
        let date = Date()
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "EEEE"
        let dayOfWeek = dformatter.string(from: date)

        
        for taskFinder in items {
            if (taskFinder.isTask == true) && (Calendar.current.isDate((taskFinder.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) != true) && (taskFinder.complete == false) && (taskFinder.notFloater == true){
                    deshuntTask(item: taskFinder)
            } else if taskFinder.notFloater == false {
                taskFinder.timestamp = Date()
            }
        }
        
        shuntTodaysTasks(viewContext: viewContext)
        
        for index in habitData {
            print("\(index.name ?? "") - \(daysBetween(start: index.startDate ?? Date(),end: Calendar.current.startOfDay(for: Date())))")
        }
        
        for index in habitData {
            
            if index.useDow == false {
                
                if (daysBetween(start: Calendar.current.startOfDay(for: index.startDate ?? Date()),
                                end: Calendar.current.startOfDay(for: Date())) >= 0)
                    && (daysBetween(start:  Calendar.current.startOfDay(for: index.startDate ?? Date()),
                                 end: Calendar.current.startOfDay(for: Date())) % Int(index.repeatValue) == 0) {
                                            
                    let newItem = Item(context: viewContext)
                    newItem.timestamp = Date()
                    newItem.name = index.name
                    newItem.goal = index.goal
                    newItem.unit = index.unit
                    newItem.whichProtocol = index.whichProtocol
                    newItem.complete = false
                    newItem.reward = index.reward
                    newItem.id = UUID()
                    newItem.hasStatus = index.hasStatus
                    newItem.hasCheckbox = index.hasCheckbox
                    newItem.notFloater = true

                }

            } else {
                
                if  (index.onMon == true && dayOfWeek == "Monday") ||
                    (index.onTues == true && dayOfWeek == "Tuesday") ||
                    (index.onWed == true && dayOfWeek == "Wednesday") ||
                    (index.onThurs == true && dayOfWeek == "Thursday") ||
                    (index.onFri == true && dayOfWeek == "Friday") ||
                    (index.onSat == true && dayOfWeek == "Saturday") ||
                    (index.onSun == true && dayOfWeek == "Sunday")
                {
                        
                    let newItem = Item(context: viewContext)
                    newItem.timestamp = Date()
                    newItem.name = index.name
                    newItem.goal = index.goal
                    newItem.unit = index.unit
                    newItem.whichProtocol = index.whichProtocol
                    newItem.complete = false
                    newItem.reward = index.reward
                    newItem.id = UUID()
                    newItem.hasStatus = index.hasStatus
                    newItem.hasCheckbox = index.hasCheckbox
                    newItem.notFloater = true
          
                }
            }
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------
    // DESHUNT TASKS
    // ---------------------------------------------------------------------------------------------------------------------


    private func deshuntTask(item: Item) {
        
        let returnedTaskItem = TaskItem(context: viewContext)
        
        returnedTaskItem.id = UUID()
        returnedTaskItem.name = item.name ?? ""
        returnedTaskItem.descript = item.descriptor ?? ""
        returnedTaskItem.reward = item.reward
        returnedTaskItem.dueDate = (calendar.date(byAdding: .day, value: 1, to: Date())!)
        returnedTaskItem.unit = item.unit ?? ""
        returnedTaskItem.goal = item.goal
        returnedTaskItem.hasCheckbox = item.hasCheckbox
        returnedTaskItem.notFloater = item.notFloater

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        deleteEntity(withUUID: item.id ?? UUID(), viewContext: viewContext)
    }
}

