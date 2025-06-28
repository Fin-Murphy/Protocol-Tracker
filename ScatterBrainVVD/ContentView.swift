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
    
    
    @State var DisplayTaskMaker: Bool = false

    @State var Today = Date()
    @State var SelectedDate: Date = Date()
    
    let valueRange = 1 ... 10
    let calendar = Calendar(identifier: .gregorian)
    
    @State var moveCompleteHabits: Bool = false
    
    @State var TaskNameSet: String = "Task"
    @State var TaskDescriptionSet: String = "This is a Task"
    @State var TaskRewardSet: Int16 = 1
    @State var TaskDueDateSet: Date = Date()
    @State var TaskUnitSet: String = "units"
    @State var TaskGoalSet: Int16 = 1
    @State var TaskHasCheckboxSet: Bool = true

    
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
                
                TaskBuilderView(context: _viewContext)
                
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
                    
                    Text("(\(Celebrate)/\(UserDefaults.standard.integer(forKey: "dailyGoal")) Points)")
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
                                                
                                                // ---------------------- BEGIN VALUE MODIFICATION
                                                
                                                if item.hasCheckbox == false {
                                                    
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
                                                    
                                                } else {
                                                    
                                                    
                                                    if item.complete == true {
                                                        Button{
                                                            subOne(item: item)
                                                        } label: {
                                                            Text("☑")
                                                                .font(.title)
                                                                .padding()
                                                                .padding()
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 10)
                                                                        .stroke(Color.black, lineWidth: 3)
                                                                )
                                                                .cornerRadius(10)
                                                        }
                                                        
                                                    } else {
                                                        Button{
                                                            addOne(item: item)
                                                        } label: {
                                                            Text("☐")
                                                                .font(.title)
                                                                .padding()
                                                                .padding()
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 10)
                                                                        .stroke(Color.black, lineWidth: 3)
                                                                )
                                                                .cornerRadius(10)
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
                                            
                                        } else {}
                                        
                                    }.onDelete(perform: deleteItems)
                                    
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
                                                
                                                // ---------------------- BEGIN VALUE MODIFICATION
                                                
                                                if item.hasCheckbox == false {
                                                    
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
                                                    
                                                } else {
                                                    
                                                    
                                                    if item.complete == true {
                                                        Button{
                                                            subOne(item: item)
                                                        } label: {
                                                            Text("☑")
                                                                .font(.title)
                                                                .padding()
                                                                .padding()
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 10)
                                                                        .stroke(Color.black, lineWidth: 3)
                                                                )
                                                                .cornerRadius(10)
                                                        }
                                                        
                                                    } else {
                                                        Button{
                                                            addOne(item: item)
                                                        } label: {
                                                            Text("☐")
                                                                .font(.title)
                                                                .padding()
                                                                .padding()
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 10)
                                                                        .stroke(Color.black, lineWidth: 3)
                                                                )
                                                                .cornerRadius(10)
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
                                            
                                        } else {}
                                        
                                    }.onDelete(perform: deleteItems)
                                    
                                    
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
                                                
                                                // ---------------------- BEGIN VALUE MODIFICATION
                                                
                                                if item.hasCheckbox == false {
                                                    
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
                                                    
                                                } else {
                                                    
                                                    
                                                    if item.complete == true {
                                                        Button{
                                                            subOne(item: item)
                                                        } label: {
                                                            Text("☑")
                                                                .font(.title)
                                                                .padding()
                                                                .padding()
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 10)
                                                                        .stroke(Color.black, lineWidth: 3)
                                                                )
                                                                .cornerRadius(10)
                                                        }
                                                        
                                                    } else {
                                                        Button{
                                                            addOne(item: item)
                                                        } label: {
                                                            Text("☐")
                                                                .font(.title)
                                                                .padding()
                                                                .padding()
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 10)
                                                                        .stroke(Color.black, lineWidth: 3)
                                                                )
                                                                .cornerRadius(10)
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
                                            
                                        } else {}
                                        
                                    }.onDelete(perform: deleteItems)

                                }
                                
                                
                               
                                
                                
                            }
                            .onAppear{moveCompleteHabits = UserDefaults.standard.bool(forKey: "displayCompletedHabits")}
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

    private func move(from source: IndexSet, to destination: Int) {
        habitData.move(fromOffsets: source, toOffset: destination)
        UserDefaults.standard.setEncodable(habitData, forKey: "habitList")
        habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
    }
    
    private func celebrationProcedure () {
            print("Goal for the day has been completed!")
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
        newItem.hasCheckbox = taskToShunt.TaskHasCheckbox
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
        
        if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {

            item.value = item.value + 1
            
            if item.value >= item.goal {
                if item.complete == false {
                    Celebrate += item.reward
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
    
    
    
    /*    ------------------------------------------------
                    SUB ONE
     ------------------------------------------------     */
    
    
    
    private func subOne(item: Item) {
        
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
        
        
//          ADD LOOP TO CHECK TASKS IN TASKLIST
        //Does this intefere with shunt/deshunt??
        
        
        if let outTaskData = UserDefaults.standard.getDecodable([Task].self, forKey: "taskList") {
            for index in outTaskData {
                if Calendar.current.isDate((index.TaskDueDate), equalTo: Date(), toGranularity: .day) == true {
                    shuntTask(taskToShunt: index)
                }
            }
        } else {
            print("Failure for task due date checker")
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
