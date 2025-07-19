//
//  TaskBuilderView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import CoreData

struct TaskBuilderView: View {
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

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
    
    @State var ProtocolTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") ?? []
    

    
    
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
                
                if ProtocolTaskData.isEmpty == false {
                
                    NavigationView {
                        List{
                            ForEach(ProtocolTaskData) { taskNdx in
                                
                                NavigationLink{
                                    
                                    ZStack {
                                        
                                        VStack{
                                            
                                            
                                            List {
                                                Text(taskNdx.TaskName)
                                                    .font(.title)
                                                    .padding()
                                                Text("Item goal: \(taskNdx.TaskGoal) \(taskNdx.TaskUnit)" )
                                                    .padding()
                                                Text("Item Description: \n")
                                                    .font(.title2)
                                                Text("\(taskNdx.TaskDescription)" )
                                                Text("Item due date: \(taskNdx.TaskDueDate, formatter: itemFormatter)")
                                                
                                            }
                                                
                                            
                                            Spacer()
                                            
                                            Button{
                                                DisplayTaskEditor = true
                                            } label: {
                                                Text("Edit Task").bckMod()
                                            }
                                            
                                            Button{
                                                shuntTask(taskToShunt: taskNdx, viewContext: context)
                                            } label: {
                                                Text("Shunt Task").bckMod()
                                            }
                                            
                                            Button{
                                                rmTask(id: taskNdx.id)
                                                //                                        selectedTab = .HUB
                                            } label: {
                                                Text("Remove this task").bckMod()
                                            }
                                            
                                            Spacer()
                                            
                                        }
                                        
                                        if DisplayTaskEditor == true {
                                            
                                            VStack {
                                                
                    
                                                Form {
                                                    
                                                    Section(header: Text("Task Name:")) {
                                                        TextField("", text: $TaskNameSet).ignoresSafeArea(.keyboard)
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
                                                            updateTask(taskToEdit: taskNdx.id)
                                                            
                                                        } label: {
                                                            Text("Save Habit")
                                                        }
                                                    }
                                                    
                                                    
                                                }.onAppear{
                                                    
                                                    TaskNameSet = taskNdx.TaskName
                                                    TaskDescriptionSet = taskNdx.TaskDescription
                                                    TaskRewardSet = taskNdx.TaskReward
                                                    TaskDueDateSet = taskNdx.TaskDueDate
                                                    TaskUnitSet = taskNdx.TaskUnit
                                                    TaskGoalSet = taskNdx.TaskGoal
                                                    TaskHasCheckboxSet = taskNdx.TaskHasCheckbox
                                                    TaskIsntFloatingSet = taskNdx.TaskNotFloater
                                                    
                                                }
                                            }
                                        } else {}
                                        
                                    }
                                    
                                } label: {
                                    Text(taskNdx.TaskName)
                                    
                                }
                                
                                
                                
                                
                            }
                        }
                    }
                } // END IF STATEMENT
                else {
                    Text("No Tasks")
                        .foregroundColor(ForeColor)
                }
                
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
            
            
            
        }//onAppear{indexProtocols()}
        
        
    }

    
    /*    ------------------------------------------------
                  ADD TASK
     ------------------------------------------------     */
    
    private func updateTask(taskToEdit: UUID) {
        
        var taskDataIteratorList: [Task] = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") ?? []
        
        for ndx in 0..<taskDataIteratorList.count {
            if taskDataIteratorList[ndx].id == taskToEdit {
                taskDataIteratorList[ndx].TaskName = TaskNameSet
                taskDataIteratorList[ndx].TaskGoal = TaskGoalSet
                taskDataIteratorList[ndx].TaskUnit = TaskUnitSet
                taskDataIteratorList[ndx].TaskDescription = TaskDescriptionSet
                taskDataIteratorList[ndx].TaskDueDate = TaskDueDateSet
                taskDataIteratorList[ndx].TaskReward = TaskRewardSet
                taskDataIteratorList[ndx].TaskHasCheckbox = TaskHasCheckboxSet
                
                if taskDataIteratorList[ndx].TaskHasCheckbox == true {
                    taskDataIteratorList[ndx].TaskGoal = 1
                    taskDataIteratorList[ndx].TaskUnit = "units"

                }
            }
        }
        
        UserDefaults.standard.setEncodable(taskDataIteratorList, forKey: "taskList")
        ProtocolTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") ?? []
        
    }
    
    
        
    private func addTask() {
        
        let inputTask:Task = Task(TaskName: TaskNameSet,
                                    TaskDescription: TaskDescriptionSet,
                                    TaskReward: TaskRewardSet,
                                    TaskDueDate: TaskDueDateSet,
                                    TaskUnit: TaskUnitSet,
                                    TaskGoal: TaskGoalSet,
                                    TaskHasCheckbox: TaskHasCheckboxSet,
                                    TaskNotFloater: TaskIsntFloatingSet)
        
        if var outTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") {

            outTaskData.append(inputTask)
            UserDefaults.standard.setEncodable(outTaskData, forKey: "taskList")
            
        } else {

            let initTaskList:[Task] = [inputTask]
            UserDefaults.standard.setEncodable(initTaskList, forKey: "taskList")
        }
        
        DisplayTaskMaker = false
        TaskNameSet = "Task"
        TaskDescriptionSet = "This is a Task"
        TaskRewardSet = 1
        TaskDueDateSet = Date()
        TaskUnitSet = "units"
        TaskGoalSet = 1
        TaskHasCheckboxSet = true
        TaskIsntFloatingSet = true
        
        
        shuntTodaysTasks(viewContext: context)
        
        ProtocolTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") ?? []

    }
    

}
