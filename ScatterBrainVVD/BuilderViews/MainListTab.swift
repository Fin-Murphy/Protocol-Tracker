//
//  MainListTab.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/16/25.
//

import SwiftUI
import CoreData

struct MainListTab: View {
    
    @Binding var selectedTab: Tabs
    
//    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    
    @Binding var Celebrate: Int16
    
    @Binding var SelectedDate: Date

    @Binding var moveCompleteHabits: Bool

    @State var habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []  // MAKE BINDING

    @State var updateItemStatus: Int16 = 0

    @State var seenWelcome: Bool = !UserDefaults.standard.bool(forKey: "seenWelcome")  // MAKE BINDING
    
//    @Binding var items: [Item]
    
    @Environment(\.managedObjectContext) public var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>


    
    
    var body: some View {
         
        VStack{
            
            DateBarView(SelectedDate: $SelectedDate, Celebrate: $Celebrate)
            
            ZStack{
                
                NavigationView {
                    
                    VStack{
                        
                        List {
                            
                            if moveCompleteHabits == true {
                                ForEach(items) { item in
                                    // How in the hell do I refactor this
                                    if (Calendar.current.isDate((item.timestamp ?? Date()), equalTo: SelectedDate, toGranularity: .day) == true && item.complete == false) || (item.notFloater == false && item.complete == false) {
                                        
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
                                    
                                    if (Calendar.current.isDate((item.timestamp ?? Date()), equalTo: SelectedDate, toGranularity: .day) == true && item.complete == true)  || (item.notFloater == false && item.complete == true) {
                                        
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
                                            
                                        } // End of navigation link
                                        label: {
                                            
                                            
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
                                    
                                    if (Calendar.current.isDate((item.timestamp ?? Date()), equalTo: SelectedDate, toGranularity: .day) == true) || (item.notFloater == false) {
                                        
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
                        //                            .toolbar {
                        //                                ToolbarItem {
                        //                                    Button(action: resetUserDefaults) {
                        //                                        Label("Add Item", systemImage: "trash")
                        //                                    }
                        //                                }
                        //                            }
                    }
                }
                
                if seenWelcome {
                    
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
                    
                    
                }
                
                
            }.onAppear{
                
                checkDate()
                
                
                
            } // END ZSTACK
            
        }
        
        
        
        
    } // END VIEWABLE CONTENT
    
    
    
    // START PRIVATE FUNCITONS
    
    
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
                newItem.notFloater = true
    
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
    
    
    
}

//#Preview {
//    MainListTab()
//}
