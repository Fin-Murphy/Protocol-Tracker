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

    
    
    @State var DisplayHabitMaker: Bool = false
    @State var DisplayTaskMaker: Bool = false

    @State var Today = Date()
    @State var SelectedDate: Date = Date()
    
    let valueRange = 1 ... 1000
    let calendar = Calendar(identifier: .gregorian)
    
    @State var HabitNameSet: String = ""
    @State var HabitValueSet: Int16 = 0
    @State var HabitGoalSet: Int16 = 1
    @State var HabitProtocolSet: String = "Daily"
    @State var HabitUnitSet: String = "units"
    @State var HabitRepetitionSet: Int = 1
    @State var HabitDescriptionSet: String = "This is a Habit"
    @State var HabitHasStatusSet: Bool = false
    @State var HabitRewardSet: Int = 1
    @State var HabitStartDateSet: Date = Date()
    @State var HabitIsSubtaskSet: Bool = false
    
    @State var TaskNameSet: String = ""
    @State var TaskDescriptionSet: String = "This is a Task"
    @State var TaskRewardSet: Int16 = 1
    @State var TaskDueDateSet: Date = Date()
    @State var TaskUnitSet: String = "units"
    @State var TaskGoalSet: Int16 = 1
    
    @State var Celebrate: Int16 = 0
    
    @State var updateItemStatus: Int16 = 0
    
    @State var habitData: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []

    //-------------------------------------------
    @State var range:Int = 4
    //----------------------------------------------------------
    
    
    
    
    @Environment(\.managedObjectContext) private var viewContext

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
                VStack{
                   
                    Button {SelectedDate = Date() } label: {Text("Current Date: \(Date(), formatter: itemFormatter)") }
                    
                    LazyHStack{
                        
                        ScrollView() {
                            LazyVStack {
                                ForEach(backward_Calendar, id: \.self){ day in
                                    
                                    Button{
                                        SelectedDate = day
                                        selectedTab = .HUB
                                    } label: {
                                        Text("\(day, formatter: itemFormatter)    ")
                                    }
                                }
                            }.padding()
                        }
                        
                        ScrollView() {
                            LazyVStack {
                                ForEach(forward_Calendar, id: \.self){ day in
                                    
                                    Button{
                                        SelectedDate = day
                                        selectedTab = .HUB
                                    } label: {
                                        Text("\(day, formatter: itemFormatter)    ")
                                    }
                                }
                            }.padding()
                        }
                        
                        
                    } // END LAZY HSTACK
                }
                
               
/* *******************************************************
                       BOOK TAB
****************************************************** */
                
            } else if selectedTab == .Settings {
                
                //PracticeView()
                
             
/* *******************************************************
             MONEY TAB
******************************************************** */
         }
            else if selectedTab == .Protocols {
                
                    
                    ZStack{
                        
                        VStack{
                            
                            HStack{
                                Text("Habits")
                                    .fontWeight(.bold)
                                    .font(.title)
                                    .padding(.bottom)
                                                                
                                Button {
                                    DisplayHabitMaker = true
                                } label: {
                                    Text("+")
                                        .foregroundColor(.blue)
                                        .font(.title)
                                        .padding(.bottom)

                                }
                            }
                                                            
                                if let listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") {
                                    if habitData.isEmpty != true {
                                        NavigationView {
                                            List {
                                                ForEach(listOfProtocols) { index in
                                                    
                                                    
                                                    Text(index.ProtocolName)
                                                        .font(.title2)
                                                        .fontWeight(.bold)
                                                        .padding(.top)
                                                    
                                                    ForEach(habitData) { habitNdx in
                                                        
                                                        if habitNdx.HabitProtocol == index.ProtocolName {
                                                            
                                                            NavigationLink{
                                                                
                                                                List{
                                                                    Text(habitNdx.HabitName)
                                                                        .font(.title)
                                                                        .padding()
                                                                    Text("Item is part of protocol \(habitNdx.HabitProtocol).")
                                                                    Text("Item start date: \(habitNdx.HabitStartDate, formatter: itemFormatter)" )
                                                                    Text("Item goal value: \(habitNdx.HabitGoal) \(habitNdx.HabitUnit)" )
                                                                    Text("Item repeats every \(habitNdx.HabitRepeatValue) days." )
                                                                    Text("Item Description: \n\n \(habitNdx.HabitDescription)" )
                                                                }

                                                             
                                                                Button{
                                                                    rmHabit(id: habitNdx.id)
                                                                    selectedTab = .HUB
                                                                } label: {
                                                                    Text("Remove this habit")
                                                                }
                                                            } label: {
                                                                
                                                                HStack {
                                                                    Text(habitNdx.HabitName)
                                                                    
                                                                    Spacer()
                                                                    
                                                                    
                                                                    Text("\(habitNdx.HabitGoal) \(habitNdx.HabitUnit)")
                                                                }
                                                            }
                                                            
                                                        } else {}
                                                    }.onMove(perform: move)
                                                }
                                            }
                                            .toolbar {
                                                EditButton()
                                            }
                                        }
                                    } else {Text("No Habits yet")}
                                }
                            }
                        
                        
                        if DisplayHabitMaker == true {
                            
                            VStack{
                                Button {
                                    DisplayHabitMaker = false
                                } label: {
                                    Image(systemName: "x.circle")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .scaledToFit()
                                        .frame(width: 100,height: 24)
                                        .bold()
                                }.padding()
                                
                                
                                    
                                    Form {
                                        
                                        Section(header: Text("Habit Name:")) {
                                            TextField("", text: $HabitNameSet)
                                        }
                                        Section(header: Text("Habit Goal:")) {
                                            TextField("", value: $HabitGoalSet, format: .number)
                                        }
                                        Section(header: Text("Habit Unit:")) {
                                            TextField("", text: $HabitUnitSet)
                                        }
                                        Section(header: Text("Habit Protocol:")) {
                                            TextField("", text: $HabitProtocolSet)
                                        }
                                        Section(header: Text("Habit Interval (1 = Daily, 7 = Weekly, etc):")) {
                                            TextField("", value: $HabitRepetitionSet, format: .number)
                                        }
                                        Section(header: Text("Habit Details")) {
                                            TextEditor(text: $HabitDescriptionSet)
                                                .frame(minHeight: 100)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                        }
                                        Section("Habit Start Date") {
                                            DatePicker("Select Date",
                                                       selection: $HabitStartDateSet,
                                                       displayedComponents: .date)
                                            .datePickerStyle(.compact)
                                        }
                                        Section(header: Text("Habit Reward (Points for completion)")) {
                                            TextField("", value: $HabitRewardSet, format: .number)
                                        }
                                        Toggle("Include status update", isOn: $HabitHasStatusSet)
                                        Toggle("Make this habit a subtask of another habit?", isOn: $HabitIsSubtaskSet)
                                        
                                        
                                        Section {
                                            Button {addItem()} label: {Text("Save Habit")}
                                            
                                            
                                        }
                                        
                                    }.ignoresSafeArea(.keyboard)
                      
                            } // VSTACK
                            .frame(width:300,height:700)
                            .cornerRadius(10)
                            .background(Rectangle()
                                .foregroundColor(.black))
                            .cornerRadius(20)
                            .shadow(radius: 20)
                            
                        } else {}
                        
                        
                    }.onAppear{indexProtocols()}
                    
                
/* *******************************************************
            GOALS TAB
****************************************************** */
            } else if selectedTab == .Goals {
                
                ZStack{
                    
                    VStack{
                        
                        HStack{
                            Text("Tasks")
                                .fontWeight(.bold)
                                .font(.title)
                                .padding(.bottom)
                            
                            
                            Button {
                                DisplayTaskMaker = true
                            } label: {
                                Text("+")
                                    .foregroundColor(.blue)
                                    .font(.title)
                                    .padding(.bottom)

                            }
                            
                            
                        }

                                if let ProtocolTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") {
                                    NavigationView {
                                        List{
                                            ForEach(ProtocolTaskData) { taskNdx in
                                                
                                                NavigationLink{
                                                    
                                                    Spacer()
                                                    
                                                    Text(taskNdx.TaskName)
                                                        .font(.title)
                                                        .padding()
                                                    Text("Item goal: \(taskNdx.TaskGoal) \(taskNdx.TaskUnit)" )
                                                        .font(.title)
                                                        .fontWeight(.bold)
                                                        .padding()
                                                    
                                                    Spacer()
                                                    
                                                    Text("Item Description: \n")
                                                        .font(.title2)
                                                    Text("\(taskNdx.TaskDescription)" )

                                                    
                                                    Spacer()

                                                    Button{
                                                        shuntTask(taskToShunt: taskNdx)
                                                    } label: {
                                                        Text("Shunt Task")
                                                            .padding()
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .stroke(Color.black, lineWidth: 3)
                                                            )
                                                            .cornerRadius(10)
                                                            .padding()
                                                    }
                                                    
                                                    Button{
                                                        rmTask(id: taskNdx.id)
                                                        selectedTab = .HUB
                                                    } label: {
                                                        Text("Remove this task")
                                                            .padding()
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .stroke(Color.black, lineWidth: 3)
                                                            )
                                                            .cornerRadius(10)
                                                            .padding()

                                                    }
                                                    
                                                    
                                                    Spacer()

                                                                                                        
                                                } label: {
                                                    Text(taskNdx.TaskName)
                                                    
                                                }
                                                
                                                
                                            }
                                        }
                                    }
                                } else {Text("No Tasks yet")}
                            
                        }
                    
                    if DisplayTaskMaker == true {
                        
                        VStack{
                            Button {
                                DisplayTaskMaker = false
                            } label: {
                                Image(systemName: "x.circle")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .scaledToFit()
                                    .frame(width: 100,height: 24)
                                    .bold()
                            }.padding()
                            
                            Form {
                                
                                Section(header: Text("Task Name:")) {
                                    TextField("", text: $TaskNameSet).ignoresSafeArea(.keyboard)
                                }
                                Section(header: Text("Task Goal:")) {
                                    TextField("", value: $TaskGoalSet, format: .number)
                                }
                                Section(header: Text("Task Unit:")) {
                                    TextField("", text: $TaskUnitSet)
                                }
                        
                                Section(header: Text("Task Details")) {
                                    TextEditor(text: $TaskDescriptionSet)
                                        .frame(minHeight: 100)
                                                      .overlay(
                                                          RoundedRectangle(cornerRadius: 8)
                                                              .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                      )
                                }
                                Section(header: Text("Task Reward (Points for completion)")) {
                                    TextField("", value: $TaskRewardSet, format: .number)
                                }
                                
                                Section {
                                    Button {addTask()} label: {Text("Save Task")}
                                }
                            }.ignoresSafeArea(.keyboard)
                            
                        } // VSTACK
                        .onTapGesture {
                            hideKeyboard()
                        }
                        .ignoresSafeArea(.keyboard)
                        .frame(width:300,height:700)
                        .cornerRadius(10)
                        .background(Rectangle()
                            .foregroundColor(.black))
                        .cornerRadius(20)
                        .shadow(radius: 20)
                        
                    } else {}
                    
                    
                }.onAppear{indexProtocols()}
                
/* *******************************************************
            MAIN TASK TAB
****************************************************** */
            } else if selectedTab == .HUB {
                
                
                // TOP DATE BAR ---------------------------------------------------------------------
                HStack{
                    
                    Button {
                        SelectedDate = calendar.date(byAdding: .day, value: -1, to: SelectedDate)!
                    } label: {
                        Text("<<")
                            .fontWeight(.bold)
                            .font(.title2)
                    }
                                        
                    Text("\(SelectedDate, formatter: itemFormatter)")
                        .fontWeight(.bold)
                        .font(.title2)
                    
                    Text("(\(Celebrate) Points)")
                        .fontWeight(.bold)
                        .font(.title2)
                    
                    Button {
                        SelectedDate = calendar.date(byAdding: .day, value: 1, to: SelectedDate)!
                        
                    } label: {
                        Text(">>")
                            .fontWeight(.bold)
                            .font(.title2)
                                            }
                }
                .colorScheme(.light)
                .background(Rectangle()
                        .foregroundColor(.white))
                // TOP DATE BAR ---------------------------------------------------------------------

                
                ZStack{
                    
                    NavigationView {
                        
                        List {
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
                                                }.ignoresSafeArea(.keyboard)
                                                .padding()
                                                .foregroundColor(.black)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.black, lineWidth: 3)
                                                )
                                                .cornerRadius(10)
                                                
                                                Button {setStatus(refItem: item)} label: {
                                                    Text("Save Habit Status")
                                                      
                                                }
                                                .foregroundColor(.blue)
                                                .padding()
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.black, lineWidth: 3)
                                                )
                                                .cornerRadius(10)
                                                   
                                            }
                                            .onAppear{updateItemStatus = item.status}
                                            .padding()
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.black, lineWidth: 3)
                                            )
                                            .cornerRadius(10)
                                            
                                        } else {}
                                        
                                        Spacer()
                                        
                                        ScrollView {
                                            if item.isTask != true {
                                                
                                                Text(displayHabitDescription(identifier: item.name ?? ""))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                                    .padding()
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.black, lineWidth: 3)
                                                    )
                                                    .cornerRadius(10)
                                                
                                            } else {
                                                
                                                Text(item.descriptor ?? "")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                                    .padding()
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.black, lineWidth: 3)
                                                    )
                                                    .cornerRadius(10)
                                            }
                                            
                                            
                                        }.frame(width: 350)
                                        
                                        Spacer()
                                        
                                        if item.complete == true {
                                            Text("☑ \(item.value)/\(item.goal) \(item.unit ?? "")")
                                                .font(.title)
                                                .padding()
                                                .padding()
                                                //.background(Color.gray.opacity(0.2))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.black, lineWidth: 3)
                                                )
                                                .cornerRadius(10)
                                        } else {
                                            Text("☐ \(item.value)/\(item.goal) \(item.unit ?? "")")
                                                .font(.title)
                                                .padding()
                                                .padding()
                                                //.background(Color.gray.opacity(0.2))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.black, lineWidth: 3)
                                                )
                                                .cornerRadius(10)
                                            
                                        }
                                        
                                        HStack{
                                            
                                            Button {
                                                addOne(item: item)
                                                if item.value == item.goal {
                                                    
                                                }
                                            }
                                            label: {
                                                Text("+ 1")
                                                    .shadow(radius: 5)
                                                    .padding()
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.black, lineWidth: 3)
                                                    )
                                                    .cornerRadius(10)
                                            }
                                                Button {
                                                    subOne(item: item)
                                                    if item.value == item.goal {
                                                        
                                                    }
                                                }
                                            label: {
                                                Text("- 1")
                                                    .shadow(radius: 5)
                                                    .padding()
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.black, lineWidth: 3)
                                                    )
                                                    .cornerRadius(10)
                                            }
                                        }
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
                                                                                        
                                            Text("\(item.value)/\(item.goal)")
                                            Text("   ")

                                        }
                                    }
                                    
                                } else {}
                            }         .onDelete(perform: deleteItems)
                            
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                EditButton()
                            }
                            ToolbarItem {
                                Button(action: resetUserDefaults) {
                                    Label("Add Item", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .environment(\.editMode, .constant(.active))
                    
                }.onAppear{checkDate()}
            }
            
            Spacer()
                        
            TabBar(selectedTab: $selectedTab)
        }.colorScheme(.light)
    }

/*    ------------------------------------------------
    
               BEGIN PRIVATE FUNCTIONS
    
 ------------------------------------------------     */

    private func move(from source: IndexSet, to destination: Int) {
        habitData.move(fromOffsets: source, toOffset: destination)
        UserDefaults.standard.setEncodable(habitData, forKey: "habitList")
        habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
    }
    
    private func celebrationProcedure () {
                
        print("Item completed!")
        
    }
    
    
    /*    ------------------------------------------------
                    SHUNT TASKS
     ------------------------------------------------     */
    
    
    private func shuntTask (taskToShunt: Task) {
        
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
        rmTask(id: taskToShunt.id)
        selectedTab = .HUB
        
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
                                    TaskGoal: item.goal)
            
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
            if Calendar.current.isDate(savedDate, equalTo: Date(), toGranularity: .day) != true {
                populateTasks()
                UserDefaults.standard.set(Date(), forKey: "DailyTaskPopulate?")
                Celebrate = 0
            }
        } else {
            UserDefaults.standard.set(Date(), forKey: "DailyTaskPopulate?")
            populateTasks()
        }
    }
    
    
    
    
    
    
    
    
    
    /*    ------------------------------------------------
                    ADD ONE
     ------------------------------------------------     */
    
    private func addOne(item: Item) {

        item.value = item.value + 1
        
        if item.value >= item.goal {
            if item.complete == false {
                Celebrate += item.reward
                celebrationProcedure()
            }
            item.complete = true
        }
     
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    
    /*    ------------------------------------------------
                    SUB ONE
     ------------------------------------------------     */
    
    
    
    private func subOne(item: Item) {
        
        if item.value > 0 {
            item.value = item.value - 1
        }
        
        if item.value < item.goal {
            if item.complete == true {
                Celebrate -= item.reward
            }
            item.complete = false
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    /*    ------------------------------------------------
                    DISPLAY HABIT DESCRIPTION
     ------------------------------------------------     */
    
    private func displayHabitDescription (identifier: String) -> String {
        
        for index in habitData {
            if index.HabitName == identifier {
                return index.HabitDescription
            }
        }
        return "No description"
    }

    
    /*    ------------------------------------------------
                   OPEN HABIT BUILDER
     ------------------------------------------------     */
    
    
    
        private func openHabitBuilder() {
            DisplayHabitMaker = true
        }
    
    
    /*    ------------------------------------------------
                   POPULATE TASKS
     ------------------------------------------------     */
    
    
    private func populateTasks() {
        for taskFinder in items {
            print("PopulateTasks checking item \(taskFinder.name ?? "")")
            if Calendar.current.isDate((taskFinder.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) != true {
                if taskFinder.complete == false {
                    deshuntTask(item: taskFinder)
                }
            } else {}
        }

        for index in habitData {
            
            if (daysBetween(start: index.HabitStartDate,end: Date()) % index.HabitRepeatValue) == 0 {
                                        
                let newItem = Item(context: viewContext)
                newItem.timestamp = Date()
                newItem.name = index.HabitName
                newItem.value = index.HabitValue
                newItem.goal = index.HabitGoal
                newItem.unit = index.HabitUnit
                newItem.whichProtocol = index.HabitProtocol
                newItem.complete = false
                newItem.reward = index.HabitReward
                newItem.id = UUID()
                newItem.hasStatus = index.HabitHasStatus
             
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
                  ADD TASK
     ------------------------------------------------     */
    
        
        private func addTask() {
            
            let inputTask:Task = Task(TaskName: TaskNameSet,
                                      TaskDescription: TaskDescriptionSet,
                                      TaskReward: TaskRewardSet,
                                      TaskDueDate: TaskDueDateSet,
                                      TaskUnit: TaskUnitSet,
                                      TaskGoal: TaskGoalSet)
            
            if var outTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") {

                outTaskData.append(inputTask)
                UserDefaults.standard.setEncodable(outTaskData, forKey: "taskList")
                
            } else {

                let initTaskList:[Task] = [inputTask]
                UserDefaults.standard.setEncodable(initTaskList, forKey: "taskList")
            }
            
            DisplayTaskMaker = false
            TaskNameSet = ""
            TaskDescriptionSet = ""
            TaskRewardSet = 0
            TaskDueDateSet = Date()
            TaskUnitSet = ""
            TaskGoalSet = 1
        }

    /*    ------------------------------------------------
                  ADD ITEM
     ------------------------------------------------     */
    
        
    private func addItem() {
        
        let inputHabit:Habit = Habit(HabitName: HabitNameSet,
                                  HabitValue: HabitValueSet,
                                  HabitGoal: HabitGoalSet,
                                  HabitUnit: HabitUnitSet,
                                  HabitProtocol: HabitProtocolSet,
                                  HabitStartDate: HabitStartDateSet,
                                  HabitRepeatValue: HabitRepetitionSet,
                                  HabitDescription: HabitDescriptionSet,
                                  HabitReward: Int16(HabitRewardSet),
                                  HabitHasStatus: HabitHasStatusSet)
        
        
        if var outData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") {

            outData.append(inputHabit)
            UserDefaults.standard.setEncodable(outData, forKey: "habitList")
            
        } else {

            let initHabitList:[Habit] = [inputHabit]
            UserDefaults.standard.setEncodable(initHabitList, forKey: "habitList")
        }
        
        
        
        DisplayHabitMaker = false
        HabitNameSet = ""
        HabitValueSet = 0
        HabitGoalSet = 1
        HabitUnitSet = "units"
        HabitProtocolSet = "Daily"
        HabitDescriptionSet = "This is a Habit"
        HabitHasStatusSet = false
        HabitRewardSet = 1
        HabitStartDateSet = Date()
        
        
        indexProtocols()
        
        habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
        
    }

    
    
    private func rmHabit(id: UUID) {
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
        
        habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
    }

    
    
    
    
    /*    ------------------------------------------------
                    RESET USER DEFAULTS
     ------------------------------------------------     */
    
    private func resetUserDefaults () {
        UserDefaults.standard.removeObject(forKey: "DailyTaskPopulate?")
        
//        UserDefaults.standard.removeObject(forKey: "habitList")
//        UserDefaults.standard.removeObject(forKey: "protocol")
//
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
