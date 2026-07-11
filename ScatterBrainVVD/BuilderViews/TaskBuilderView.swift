//
//  TaskBuilderView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import SwiftData

struct TaskBuilderView: View {

    @Query(sort: \taskItem.name, animation: .default)
    private var taskData: [taskItem]

    @Environment(\.modelContext) private var modelContext
    
    @State var DisplayTaskMaker: Bool = false
    @State var DisplayTaskEditor: Bool = false
    
    @State var TaskNameSet: String = "Task"
    @State var TaskDescriptionSet: String = ""
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

                if taskData.isEmpty == false {

                    NavigationView {
                        List{
                            ForEach(taskData) { taskNdx in
                                
                                NavigationLink{
                                    
                                    ZStack {
                                        
                                        VStack{
                                            
                                            List {
                                                Text(taskNdx.name)
                                                    .font(.title)
                                                    .padding()
                                                Text("Item goal: \(taskNdx.goal) \(taskNdx.unit)" )
                                                Text("Item due date: \(taskNdx.dueDate, formatter: itemFormatter)")
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
                                                shuntTask(taskToShunt: taskNdx, modelContext: modelContext)

                                            } label: {
                                                Text("Shunt Task").bckMod()
                                            }

                                            Button{
                                                deleteEntityTask(withUUID: taskNdx.id, modelContext: modelContext)
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
                                                    
                                                    Toggle("Task doesn't Persist", isOn: $TaskIsntFloatingSet)
                                                    Section("TaskStart Date") {
                                                        DatePicker("Select Date",
                                                                   selection: $TaskDueDateSet,
                                                                   displayedComponents: .date)
                                                        .datePickerStyle(.compact)
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

                                                    TaskNameSet = taskNdx.name
                                                    TaskDescriptionSet = taskNdx.descript
                                                    TaskRewardSet = Int16(taskNdx.reward)
                                                    TaskDueDateSet = taskNdx.dueDate
                                                    TaskUnitSet = taskNdx.unit
                                                    TaskGoalSet = Int16(taskNdx.goal)
                                                    TaskHasCheckboxSet = taskNdx.hasCheckbox
                                                    TaskIsntFloatingSet = taskNdx.notFloater

                                                }
                                            }
                                        } else {}
                                        
                                    }
                                    
                                } label: {
                                    Text(taskNdx.name)

                                }
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
                        
                        
                        Toggle("Task doesn't Persist", isOn: $TaskIsntFloatingSet)
                        Section("Task Date") {
                            DatePicker("Select Date",
                                       selection: $TaskDueDateSet,
                                       displayedComponents: .date)
                            .datePickerStyle(.compact)
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
    
    private func updateTask(taskToEdit: taskItem) {

        taskToEdit.name = TaskNameSet
        taskToEdit.goal = Int(TaskGoalSet)
        taskToEdit.unit = TaskUnitSet
        taskToEdit.descript = TaskDescriptionSet
        taskToEdit.dueDate = TaskDueDateSet
        taskToEdit.reward = Int(TaskRewardSet)
        taskToEdit.hasCheckbox = TaskHasCheckboxSet

        if taskToEdit.hasCheckbox == true {
            taskToEdit.goal = 1
            taskToEdit.unit = "units"
        }

        saveContext(modelContext: modelContext)
    }

    private func addTask() {

        if TaskHasCheckboxSet == true {
            TaskGoalSet = 1
        }

        let newTaskItem = taskItem(descript: TaskDescriptionSet,
                                   dueDate: TaskDueDateSet,
                                   goal: Int(TaskGoalSet),
                                   hasCheckbox: TaskHasCheckboxSet,
                                   id: UUID(),
                                   name: TaskNameSet,
                                   notFloater: TaskIsntFloatingSet,
                                   reward: Int(TaskRewardSet),
                                   unit: TaskUnitSet)

        modelContext.insert(newTaskItem)
        saveContext(modelContext: modelContext)


        DisplayTaskMaker = false
        TaskNameSet = "Task"
        TaskDescriptionSet = ""
        TaskRewardSet = 1
        TaskDueDateSet = Date()
        TaskUnitSet = "units"
        TaskGoalSet = 1
        TaskHasCheckboxSet = true
        TaskIsntFloatingSet = true
        
        shuntTodaysTasks(modelContext: modelContext)

    }


}

//#Preview {
//    TaskBuilderView()
//}
