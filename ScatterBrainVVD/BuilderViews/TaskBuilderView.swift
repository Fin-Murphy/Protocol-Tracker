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
    
    @State var TaskNameSet: String = "Task"
    @State var TaskDescriptionSet: String = "This is a Task"
    @State var TaskRewardSet: Int16 = 1
    @State var TaskDueDateSet: Date = Date()
    @State var TaskUnitSet: String = "units"
    @State var TaskGoalSet: Int16 = 1
    @State var TaskHasCheckboxSet: Bool = true
    
    
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
                                    
                                    Text("Item due date: \(taskNdx.TaskDueDate)")
                                    
                                    
                                    Spacer()
                                    
                                    Button{
                                        shuntTask(taskToShunt: taskNdx, viewContext: context)
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
//                                        selectedTab = .HUB
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
                        Toggle("Use checkbox instead of units", isOn: $TaskHasCheckboxSet)
                        if TaskHasCheckboxSet == false {
                            Section(header: Text("Task Goal:")) {
                                TextField("", value: $TaskGoalSet, format: .number)
                            }
                            Section(header: Text("Task Unit:")) {
                                TextField("", text: $TaskUnitSet)
                            }
                        }
                        
                        Section("Task Due Date") {
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
            
            
        }//onAppear{indexProtocols()}
        
        
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
                                    TaskGoal: TaskGoalSet,
                                    TaskHasCheckbox: TaskHasCheckboxSet)
        
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
        TaskHasCheckboxSet = false
    }
    
    /*    ------------------------------------------------
                  INDEX PROTOCOLS
     ------------------------------------------------     */
    /*
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
     */
}

//#Preview {
//    TaskBuilderView(context: <#Binding<NSManagedObjectContext>#>)
//}
