//
//  TaskBuilderView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import CoreData

struct TaskBuilderView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.name, ascending: true)],
        animation: .default)
    private var taskData: FetchedResults<TaskItem>
    
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext

    @Binding var selectedTab: Tabs
    
    @State var DisplayTaskMaker: Bool = false
    @State var DisplayTaskEditor: Bool = false
    
    @State var TaskNameSet: String = "Task"
    @State var TaskDescriptionSet: String = "This is a Task"
    @State var TaskRewardSet: Int16 = 1
    @State var TaskDueDateSet: Date = Date()
    @State var TaskUnitSet: String = "units"
    @State var TaskGoalSet: Int16 = 1
    @State var TaskHasCheckboxSet: Bool = true
    @State var TaskIsntFloatingSet: Bool = true
    
    
    var body: some View {
        
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
                            .font(.title)
                            .padding(.bottom)
                        
                    }
                    
                    
                }.foregroundColor(ForeColor)
//                
                if taskData.isEmpty == false {
//                
                    NavigationView {
                        List{
                            ForEach(taskData) { taskNdx in
//                                
                                NavigationLink{
//                                    
                                    ZStack {
//                                        
                                        VStack{
                                            
                                            List {
                                                Text(taskNdx.name ?? "")
                                                    .font(.title)
                                                    .padding()
                                                Text("Item goal: \(taskNdx.goal) \(taskNdx.unit ?? "")" )
                                                Text("Item due date: \(taskNdx.dueDate ?? Date(), formatter: itemFormatter)")
                                                Section {
                                                    Text("Item Description: \n")
                                                        .font(.title2)
                                                    Text("\(String(describing: taskNdx.descript))" )
                                                }
                                            }
                                                
                                            
                                            Spacer()
                                            
                                            Button{
                                                DisplayTaskEditor = true
                                            } label: {
                                                Text("Edit Task").bckMod()
                                            }
                                            
                                            Button{
                                                shuntTask(taskToShunt: taskNdx, viewContext: viewContext)
//                                                taskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") ?? []
                                            } label: {
                                                Text("Shunt Task").bckMod()
                                            }
                                            
                                            Button{
                                                deleteEntityTask(withUUID: taskNdx.id ?? UUID(), viewContext: viewContext)
                                            } label: {
                                                Text("Remove this task").bckMod()
                                            }
                                            
                                            Spacer()
                                            
                                        }
                                        
                                        if DisplayTaskEditor == true {
                                            
                                            VStack {
                                                
                    
                                                Form {
                                                    
                                                    Section(header: Text("Task Name:")) {
                                                        TextField("", text: $TaskNameSet)
                                                    }
                                                    Toggle("Use checkbox instead of units", isOn: $TaskHasCheckboxSet)
                                                    if TaskHasCheckboxSet == false {
                                                        Section(header: Text("Task Goal:")) {
                                                            TextField("", value: $TaskGoalSet, format: .number)
                                                        }
                                                        Section(header: Text("Task Unit:")) {
                                                            TextField("", text: $TaskUnitSet)
                                                        }
                                                    }
                                                    
                                                    Toggle("Schedule task", isOn: $TaskIsntFloatingSet)
                                                    if TaskIsntFloatingSet == true {
                                                        Section("Task Date") {
                                                            DatePicker("Select Date",
                                                                       selection: $TaskDueDateSet,
                                                                       displayedComponents: .date)
                                                            .datePickerStyle(.compact)
                                                        }
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
                                                    
                                                    
                                                    Section{
                                                        Button{
                                                            DisplayTaskEditor = false
                                                            updateTask(taskToEdit: taskNdx)
                                                            
                                                        } label: {
                                                            Text("Save Habit")
                                                        }
                                                    }
                                                    
                                                    
                                                }.onAppear{
                                                    
                                                    TaskNameSet = taskNdx.name ?? ""
                                                    TaskDescriptionSet = taskNdx.descript ?? ""
                                                    TaskRewardSet = taskNdx.reward
                                                    TaskDueDateSet = taskNdx.dueDate ?? Date()
                                                    TaskUnitSet = taskNdx.unit ?? ""
                                                    TaskGoalSet = taskNdx.goal
                                                    TaskHasCheckboxSet = taskNdx.hasCheckbox
                                                    TaskIsntFloatingSet = taskNdx.notFloater
                                                    
                                                }
                                            }
                                        } else {}
//                                        
                                    }
//                                    
                                } label: {
                                    Text(taskNdx.name ?? "")
                                    
                                }
//                                
//                                
//                                
//                                
                            }
                        }
                    }
                } // END IF STATEMENT
                else {
                    Text("No Tasks")
                        .foregroundColor(ForeColor)
                }
                
            } // End Vstack
            
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
                            TextField("", text: $TaskNameSet)
                        }
                        Toggle("Use checkbox instead of units", isOn: $TaskHasCheckboxSet)
                        if TaskHasCheckboxSet == false {
                            Section(header: Text("Task Goal:")) {
                                TextField("", value: $TaskGoalSet, format: .number)
                            }
                            Section(header: Text("Task Unit:")) {
                                TextField("", text: $TaskUnitSet)
                            }
                        }
                        
                        
                        Toggle("Schedule task", isOn: $TaskIsntFloatingSet)
                        if TaskIsntFloatingSet == true {
                            Section("Task Date") {
                                DatePicker("Select Date",
                                           selection: $TaskDueDateSet,
                                           displayedComponents: .date)
                                .datePickerStyle(.compact)
                            }
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
                    }
                    
                } // VSTACK
                .frame(width:300,height:700)
                .cornerRadius(10)
                .background(Rectangle()
                    .foregroundColor(.black))
                .cornerRadius(20)
                .shadow(radius: 20)
                
            } else {}
            
            
            
        }
        
        
    }

    
    /*    ------------------------------------------------
                  ADD TASK
     ------------------------------------------------     */
    
    private func updateTask(taskToEdit: TaskItem) {

                
                
        taskToEdit.name = TaskNameSet
        taskToEdit.goal = TaskGoalSet
        taskToEdit.unit = TaskUnitSet
        taskToEdit.descript = TaskDescriptionSet
        taskToEdit.dueDate = TaskDueDateSet
        taskToEdit.reward = TaskRewardSet
        taskToEdit.hasCheckbox = TaskHasCheckboxSet
                
        if taskToEdit.hasCheckbox == true {
            taskToEdit.goal = 1
            taskToEdit.unit = "units"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        

    }
    
    
        
    private func addTask() {
        
        if TaskHasCheckboxSet == true {
            TaskGoalSet = 1
        }
        
        let newTaskItem = TaskItem(context: viewContext)
        
        newTaskItem.id = UUID()
        
        newTaskItem.name = TaskNameSet
        newTaskItem.goal = TaskGoalSet
        newTaskItem.unit = TaskUnitSet
        newTaskItem.descript = TaskDescriptionSet
        newTaskItem.reward = TaskRewardSet
        newTaskItem.dueDate = TaskDueDateSet
        newTaskItem.hasCheckbox = TaskHasCheckboxSet
        newTaskItem.notFloater = TaskIsntFloatingSet

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        
        DisplayTaskMaker = false
        TaskNameSet = "Task"
        TaskDescriptionSet = ""
        TaskRewardSet = 1
        TaskDueDateSet = Date()
        TaskUnitSet = "units"
        TaskGoalSet = 1
        TaskHasCheckboxSet = true
        TaskIsntFloatingSet = true
        
        shuntTodaysTasks(viewContext: viewContext)
     
    }
    
    func shuntTodaysTasks (viewContext: NSManagedObjectContext) {
        
        for index in taskData {
            if (Calendar.current.isDate((index.dueDate ?? Date()), equalTo: Date(), toGranularity: .day) == true) && (index.notFloater == true) {
                shuntTask(taskToShunt: index, viewContext: viewContext)
            }
        }
    }

}
