//
//  ContentView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/20/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State var selectedTab: Tabs = .HUB
    
    @State var SelectedDate: Date = Date()
    
    let calendar = Calendar(identifier: .gregorian)
    
    @State var moveCompleteHabits: Bool = false
    
    @State var Celebrate: Int16 = 0
    
    @State var updateItemStatus: Int16 = 0
    
    @State var habitData: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []

    //-------------------------------------------
    @State var range:Int = 4
    //----------------------------------------------------------
    
    
    @Environment(\.managedObjectContext) public var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    
   
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
                                    
                HabitBuilderView()
                    
                
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
           
                DateBarView(SelectedDate: $SelectedDate, Celebrate: $Celebrate)
                
                // TOP DATE BAR ---------------------------------------------------------------------

                
                ZStack{
                    
                    NavigationView {
                        
                        VStack{
                            
                            List {
                                
                                if moveCompleteHabits == true {
                                    ForEach(items) { item in
                                        
                                        if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: SelectedDate, toGranularity: .day) == true && item.complete == false {
                                            
                                            NavigationLink {
                                                
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

                                                        Button {setStatus(refItem: item)} label: {
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
                                                        
                                                        Text(displayHabitDescription(identifier: item.name ?? ""))
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .padding()
                                                            .bckMod()
                                                        
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
                                                            if item.value == item.goal {
                                                                
                                                            }
                                                        }
                                                        label: {
                                                            Text("+ 1")
                                                                .bckMod()
                                                        }
                                                        Button {
                                                            subOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
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
                                                        } label: {
                                                            Text("☑")
                                                                .font(.title)
                                                                .padding()
                                                                .bckMod()
                                                        }
                                                        
                                                    } else {
                                                        Button{
                                                            addOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                                                        } label: {
                                                            Text("☐")
                                                                .font(.title)
                                                                .padding()
                                                                .bckMod()
                                                        }
                                                    }
                                                }
                                                // ---------------------- END VALUE MODIFICATION
                                                
                                                
                                                Spacer()
                                                
                                            } label: {
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
                                                    deleteEntity(withUUID: item.id ?? UUID())
                                                }
                                                .tint(.red)
                                            }

                                            
                                        } else {}
                                        
                                    }
                                    
                                    ForEach(items) { item in
                                        
                                        if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: SelectedDate, toGranularity: .day) == true && item.complete == true {
                                            
                                            NavigationLink {
                                                
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

                                                        
                                                        Button {setStatus(refItem: item)} label: {
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
                                                        
                                                        Text(displayHabitDescription(identifier: item.name ?? ""))
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .padding()
                                                            .bckMod()

                                                        
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
                                                            if item.value == item.goal {
                                                                
                                                            }
                                                        }
                                                        label: {
                                                            Text("+ 1")
                                                                .shadow(radius: 5)
                                                                .bckMod()

                                                        }
                                                        Button {
                                                            subOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
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
                                                        } label: {
                                                            Text("☑")
                                                                .font(.title)
                                                                .padding()
                                                                .bckMod()

                                                        }
                                                        
                                                    } else {
                                                        Button{
                                                            addOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                                                        } label: {
                                                            Text("☐")
                                                                .font(.title)
                                                                .padding()
                                                                .bckMod()

                                                        }
                                                    }
                                                }
                                                // ---------------------- END VALUE MODIFICATION
                                                
                                                
                                                Spacer()
                                                
                                            } label: {
                                                
                                                
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
                                                    deleteEntity(withUUID: item.id ?? UUID())
                                                }
                                                .tint(.red)
                                            }
                                        } else {}
                                        
                                    }
                                    
                                    
                                } else {

                                    ForEach(items) { item in
                                        
                                        if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: SelectedDate, toGranularity: .day) == true {
                                            
                                            NavigationLink {
                                                
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
                                                        }.bckMod()
                                                        
                                                        Button {setStatus(refItem: item)} label: {
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
                                                        
                                                        Text(displayHabitDescription(identifier: item.name ?? ""))
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .padding()
                                                            .bckMod()

                                                        
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
                                                            if item.value == item.goal {
                                                                
                                                            }
                                                        }
                                                        label: {
                                                            Text("+ 1")
                                                                .shadow(radius: 5)
                                                                .bckMod()

                                                        }
                                                        Button {
                                                            subOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                                                            if item.value == item.goal {
                                                                
                                                            }
                                                        }
                                                        label: {
                                                            Text("- 1")
                                                                .shadow(radius: 5)
                                                                .bckMod()

                                                        }
                                                    }
                                                    
                                                } else {
                                                    
                                                    
                                                    if item.complete == true {
                                                        Button{
                                                            subOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                                                        } label: {
                                                            Text("☑")
                                                                .font(.title)
                                                                .padding()
                                                                .bckMod()

                                                        }
                                                        
                                                    } else {
                                                        Button{
                                                            addOne(item: item, viewContext: viewContext, Celebrate: &Celebrate)
                                                        } label: {
                                                            Text("☐")
                                                                .font(.title)
                                                                .padding()
                                                                .bckMod()

                                                        }
                                                    }
                                                }
                                                // ---------------------- END VALUE MODIFICATION
                                                
                                                
                                                Spacer()
                                                
                                            } label: {
                                                
                                                
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
                                                    deleteEntity(withUUID: item.id ?? UUID())
                                                }
                                                .tint(.red)
                                            }
                                            
                                            
                                        } else {}
                                        
                                    }
                                }
                        
                            }
                            .onAppear{
                                moveCompleteHabits = UserDefaults.standard.bool(forKey: "displayCompletedHabits")
                            }
                            .toolbar {
                                ToolbarItem {
                                    Button(action: resetUserDefaults) {
                                        Label("Add Item", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }.onAppear{checkDate()}
            }
            
            Spacer()
                        
            TabBar(selectedTab: $selectedTab)
        }.colorScheme(.light)
    }

/*    ------------------------------------------------
                   BEGIN PRIVATE FUNCTIONS
     ------------------------------------------------     */


    
    /*    ------------------------------------------------
                    DESHUNT TASKS
     ------------------------------------------------     */
    
    private func deshuntTask(item: Item) {
        print("Running deshunt for item \(item.name ?? "")")
        if item.isTask == true {
            print("Successful!")
            let returnedTask = Task(id: UUID(),
                                    TaskName: item.name ?? "",
                                    TaskDescription: item.descriptor ?? "",
                                    TaskReward: item.reward,
                                    TaskDueDate: (item.timestamp ?? Date()),
                                    TaskUnit: item.unit ?? "",
                                    TaskGoal: item.goal,
                                    TaskHasCheckbox: item.hasCheckbox)
            
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
    
    /*    ------------------------------------------------
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
    
    /*    ------------------------------------------------
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
                    INDEX PROTOCOLS
     ------------------------------------------------     */
    
    
    private func indexProtocols () {
        
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
            print("PopulateTasks checking item \(taskFinder.name ?? "")")
            if Calendar.current.isDate((taskFinder.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) != true {
                if taskFinder.complete == false {
                    deshuntTask(item: taskFinder)
                }
            } else {}
        }
        
        checkTaskDueDates(viewContext: viewContext)
        
        for index in habitData {
            print("\(index.HabitName) has had \(daysBetween(start: index.HabitStartDate,end: Date()) % index.HabitRepeatValue + 1) days since inception")
        }

        for index in habitData {
            
            if (daysBetween(start: index.HabitStartDate,end: Date()) % index.HabitRepeatValue) == 0 {
                                        
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
