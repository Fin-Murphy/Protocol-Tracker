//
//  HabitBuilderView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import CoreData

struct HabitBuilderView: View {
    
    
    
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext

    @Binding var selectedTab: Tabs
    
    @State var habitData: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
    
    @State var DisplayHabitMaker: Bool = false
    @State var DisplayHabitEditor: Bool = false
    
    
    @State var HabitNameSet: String = ""
    @State var HabitGoalSet: Int16 = 1
    @State var HabitProtocolSet: String = "Daily"
    @State var HabitUnitSet: String = "units"
    @State var HabitRepetitionSet: Int = 1
    @State var HabitDescriptionSet: String = ""
    @State var HabitHasStatusSet: Bool = false
    @State var HabitRewardSet: Int16 = 1
    @State var HabitStartDateSet: Date = Date()
    @State var HabitHasCheckboxSet: Bool = true
    @State var HabitIsSubtaskSet: Bool = false
    @State var HabitHasSubTaskSet: Bool = false
    @State var HabitSuperTaskSet: UUID? = nil
    
    @State var HabitUseDOWSet: Bool = false
    // -------------------------------------- DOW REP VALS
    @State var HabitOnMonSet: Bool = false
    @State var HabitOnTuesSet: Bool = false
    @State var HabitOnWedSet: Bool = false
    @State var HabitOnThursSet: Bool = false
    @State var HabitOnFriSet: Bool = false
    @State var HabitOnSatSet: Bool = false
    @State var HabitOnSunSet: Bool = false
    // --------------------------------------

    @State var displayByProtocol: Bool = false
    
    private var habLister: some View {
        ForEach(habitData){ superTaskHabit in
            
            if superTaskHabit.HabitIsSubtask == false {
                Button{
                    HabitSuperTaskSet = superTaskHabit.id
                } label: {
                    Text(superTaskHabit.HabitName)
                }
            }
        }
    }
    
    private var habitBuilderForm: some View {
        
        Form {
            Section(header: Text("Habit Name:")) {
                TextField("", text: $HabitNameSet)
            }
            Toggle("Use checkbox instead of units",isOn: $HabitHasCheckboxSet)
            if HabitHasCheckboxSet == false {
                Section(header: Text("Habit Goal:")) {
                    TextField("", value: $HabitGoalSet, format: .number)
                }
                Section(header: Text("Habit Unit:")) {
                    TextField("", text: $HabitUnitSet)
                }
            }
            
//            Toggle("Make this habit a subhabit of another habit?", isOn: $HabitIsSubtaskSet)
//            if HabitIsSubtaskSet == true {
//                
//                Text("Superhabit: \(displayNameByUUID(id: HabitSuperTaskSet ?? UUID()))")
//                
//                    habLister
//          
//            } else {
            
                Toggle("Choose days of the week to repeat on?", isOn: $HabitUseDOWSet)
                if HabitUseDOWSet == true {
                    Toggle("Repeat on Sunday", isOn: $HabitOnSunSet)
                    Toggle("Repeat on Monday", isOn: $HabitOnMonSet)
                    Toggle("Repeat on Tuesday", isOn: $HabitOnTuesSet)
                    Toggle("Repeat on Wednesday", isOn: $HabitOnWedSet)
                    Toggle("Repeat on Thursday", isOn: $HabitOnThursSet)
                    Toggle("Repeat on Friday", isOn: $HabitOnFriSet)
                    Toggle("Repeat on Saturday", isOn: $HabitOnSatSet)
                } else {
                    Section(header: Text("Habit Interval (1 = Daily, 7 = Weekly, etc):")) {
                        TextField("", value: $HabitRepetitionSet, format: .number)
                    }
                }
                
                Section(header: Text("Habit Protocol:")) {
                    TextField("", text: $HabitProtocolSet)
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
            
//            }
            Section {
                Button {addItem()} label: {Text("Save Habit")}
            }
        }
    }
    
    // -----------------------------------------------
    //                  END VAR DECLARATIONS
    // ----------------------------------------------
    
    var body: some View {
        
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
                            .font(.title)
                            .padding(.bottom)
                    }
                }.foregroundColor(ForeColor)
                    Toggle("Display by Protocol", isOn: $displayByProtocol).frame(maxWidth: 210)
                
                if let listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") {

                if habitData.isEmpty != true {
                    
                        NavigationView {
                            
                            List {
                                if displayByProtocol == true {
                                    ForEach(listOfProtocols) { index in
                                        
                                        Text(index.ProtocolName)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .padding(.top)
                                        
                                        ForEach(habitData) { habitNdx in
                                            
                                            if habitNdx.HabitProtocol == index.ProtocolName && habitNdx.HabitIsSubtask == false {
                                                
                                                NavigationLink{
                                                    ZStack{
                                                        VStack {
                                                   
//                                                            HabitDetailView(habitNdx: habitNdx)
                                                            
                                                            List{
                                                                Text(habitNdx.HabitName)
                                                                    .font(.title)
                                                                    .padding()
                                                                Text("Item is part of protocol \(habitNdx.HabitProtocol).")
                                                                Text("Item start date: \(habitNdx.HabitStartDate, formatter: itemFormatter)" )
                                                                Text("Item goal value: \(habitNdx.HabitGoal) \(habitNdx.HabitUnit)" )
                                                                Text("Item repeats every \(habitNdx.HabitRepeatValue) days." )
                                                                Text("Item Description: \n\n \(habitNdx.HabitDescription)" )
                                                                if habitNdx.HabitHasSubtask == true {
                                                                    Text("Subhabits:")
                                                                    ForEach(habitData){ indexr in
                                                                        if indexr.HabitSuperTask == habitNdx.id {
                                                                            Text(indexr.HabitName)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                                                                                    
                                                            Button{DisplayHabitEditor = true} label: {
                                                                Text("Edit habit")
                                                            }
                                                            Button{rmHabit(id: habitNdx.id)} label: {
                                                                Text("Remove this habit")
                                                            }
                                                        }
                                                        
                                                        if DisplayHabitEditor == true {
                                                            
                                                            Form {

                                                                Section(header: Text("Habit Name:")) {
                                                                    TextField("", text: $HabitNameSet)
                                                                }
                                                                Toggle("Use checkbox instead of units",isOn: $HabitHasCheckboxSet)
                                                                if HabitHasCheckboxSet == false {
                                                                    Section(header: Text("Habit Goal:")) {
                                                                        TextField("", value: $HabitGoalSet, format: .number)
                                                                    }
                                                                    Section(header: Text("Habit Unit:")) {
                                                                        TextField("", text: $HabitUnitSet)
                                                                    }
                                                                }
                                                                
                                                                
                                                                Toggle("Choose days of the week to repeat on?", isOn: $HabitUseDOWSet)
                                                                if HabitUseDOWSet == true {
                                                                    Toggle("Repeat on Sunday", isOn: $HabitOnSunSet)
                                                                    Toggle("Repeat on Monday", isOn: $HabitOnMonSet)
                                                                    Toggle("Repeat on Tuesday", isOn: $HabitOnTuesSet)
                                                                    Toggle("Repeat on Wednesday", isOn: $HabitOnWedSet)
                                                                    Toggle("Repeat on Thursday", isOn: $HabitOnThursSet)
                                                                    Toggle("Repeat on Friday", isOn: $HabitOnFriSet)
                                                                    Toggle("Repeat on Saturday", isOn: $HabitOnSatSet)
                                                                } else {
                                                                    Section(header: Text("Habit Interval (1 = Daily, 7 = Weekly, etc):")) {
                                                                        TextField("", value: $HabitRepetitionSet, format: .number)
                                                                    }
                                                                }
                                                                
                                                                Section(header: Text("Habit Protocol:")) {
                                                                    TextField("", text: $HabitProtocolSet)
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
                                                                Section {
                                                                    Button {
                                                                        //------------------------------------
                                                                        updateHabit(habitToEdit: habitNdx.id)
                                                                        //------------------------------------
                                                                        DisplayHabitEditor = false
                                                                        indexProtocols()
                                                                        
                                                                        habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []

                                                                        //crap commit
                                                                    } label: {Text("Save Habit")}
                                                                }
                                                            }
                                                            .onAppear{
                                                                HabitNameSet = habitNdx.HabitName
                                                                HabitGoalSet = habitNdx.HabitGoal
                                                                HabitUnitSet = habitNdx.HabitUnit
                                                                HabitProtocolSet = habitNdx.HabitProtocol
                                                                HabitRepetitionSet = habitNdx.HabitRepeatValue
                                                                HabitDescriptionSet = habitNdx.HabitDescription
                                                                HabitStartDateSet = habitNdx.HabitStartDate
                                                                HabitRewardSet = habitNdx.HabitReward
                                                                HabitHasCheckboxSet = habitNdx.HabitHasCheckbox
                                                                HabitHasStatusSet = habitNdx.HabitHasStatus
                                                                
                                                                HabitUseDOWSet = habitNdx.HabitUseDow
                                                                
                                                                HabitOnSunSet = habitNdx.HabitOnSun
                                                                HabitOnMonSet = habitNdx.HabitOnMon
                                                                HabitOnTuesSet = habitNdx.HabitOnTues
                                                                HabitOnWedSet = habitNdx.HabitOnWed
                                                                HabitOnThursSet = habitNdx.HabitOnThurs
                                                                HabitOnFriSet = habitNdx.HabitOnFri
                                                                HabitOnSatSet = habitNdx.HabitOnSat
                                                                
                                                            }
                                                        } else {}
                                                    }
                                                } label: {
                                                    HStack {
                                                        //-----------------------------------------------------
                                                        Text(habitNdx.HabitName)
                                                        
                                                        Spacer()
                                                        
                                                        Text("\(habitNdx.HabitGoal) \(habitNdx.HabitUnit)")
                                                        //-----------------------------------------------------
                                                    }
                                                }
                                            } else {}
                                        }.onMove(perform: move)
                                    }
                                } else {
                                    
                                    ForEach(habitData) { habitNdx in
                                        
                                        if habitNdx.HabitIsSubtask == false {
                                            
                                            NavigationLink{
                                                ZStack{
                                                    VStack {
                                               
//                                                        HabitDetailView(habitNdx: habitNdx)
                                                        
                                                        List{
                                                            Text(habitNdx.HabitName)
                                                                .font(.title)
                                                                .padding()
                                                            Text("Item is part of protocol \(habitNdx.HabitProtocol).")
                                                            Text("Item start date: \(habitNdx.HabitStartDate, formatter: itemFormatter)" )
                                                            Text("Item goal value: \(habitNdx.HabitGoal) \(habitNdx.HabitUnit)" )
                                                            Text("Item repeats every \(habitNdx.HabitRepeatValue) days." )
                                                            Text("Item Description: \n\n \(habitNdx.HabitDescription)" )
                                                            if habitNdx.HabitHasSubtask == true {
                                                                Text("Subhabits:")
                                                                ForEach(habitData){ indexr in
                                                                    if indexr.HabitSuperTask == habitNdx.id {
                                                                        Text(indexr.HabitName)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                                                                                
                                                        Button{DisplayHabitEditor = true} label: {
                                                            Text("Edit habit")
                                                        }
                                                        Button{rmHabit(id: habitNdx.id)} label: {
                                                            Text("Remove this habit")
                                                        }
                                                    }
                                                    
                                                    if DisplayHabitEditor == true {
                                                        
                                                        Form {

                                                            Section(header: Text("Habit Name:")) {
                                                                TextField("", text: $HabitNameSet)
                                                            }
                                                            Toggle("Use checkbox instead of units",isOn: $HabitHasCheckboxSet)
                                                            if HabitHasCheckboxSet == false {
                                                                Section(header: Text("Habit Goal:")) {
                                                                    TextField("", value: $HabitGoalSet, format: .number)
                                                                }
                                                                Section(header: Text("Habit Unit:")) {
                                                                    TextField("", text: $HabitUnitSet)
                                                                }
                                                            }
                                                            
                                                            
                                                            Toggle("Choose days of the week to repeat on?", isOn: $HabitUseDOWSet)
                                                            if HabitUseDOWSet == true {
                                                                Toggle("Repeat on Sunday", isOn: $HabitOnSunSet)
                                                                Toggle("Repeat on Monday", isOn: $HabitOnMonSet)
                                                                Toggle("Repeat on Tuesday", isOn: $HabitOnTuesSet)
                                                                Toggle("Repeat on Wednesday", isOn: $HabitOnWedSet)
                                                                Toggle("Repeat on Thursday", isOn: $HabitOnThursSet)
                                                                Toggle("Repeat on Friday", isOn: $HabitOnFriSet)
                                                                Toggle("Repeat on Saturday", isOn: $HabitOnSatSet)
                                                            } else {
                                                                Section(header: Text("Habit Interval (1 = Daily, 7 = Weekly, etc):")) {
                                                                    TextField("", value: $HabitRepetitionSet, format: .number)
                                                                }
                                                            }
                                                            
                                                            Section(header: Text("Habit Protocol:")) {
                                                                TextField("", text: $HabitProtocolSet)
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
                                                            Section {
                                                                Button {
                                                                    //------------------------------------
                                                                    updateHabit(habitToEdit: habitNdx.id)
                                                                    //------------------------------------
                                                                    DisplayHabitEditor = false
                                                                    indexProtocols()
                                                                    
                                                                    habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []

                                                                    //crap commit
                                                                } label: {Text("Save Habit")}
                                                            }
                                                        }
                                                        .onAppear{
                                                            HabitNameSet = habitNdx.HabitName
                                                            HabitGoalSet = habitNdx.HabitGoal
                                                            HabitUnitSet = habitNdx.HabitUnit
                                                            HabitProtocolSet = habitNdx.HabitProtocol
                                                            HabitRepetitionSet = habitNdx.HabitRepeatValue
                                                            HabitDescriptionSet = habitNdx.HabitDescription
                                                            HabitStartDateSet = habitNdx.HabitStartDate
                                                            HabitRewardSet = habitNdx.HabitReward
                                                            HabitHasCheckboxSet = habitNdx.HabitHasCheckbox
                                                            HabitHasStatusSet = habitNdx.HabitHasStatus
                                                            
                                                            HabitUseDOWSet = habitNdx.HabitUseDow
                                                            
                                                            HabitOnSunSet = habitNdx.HabitOnSun
                                                            HabitOnMonSet = habitNdx.HabitOnMon
                                                            HabitOnTuesSet = habitNdx.HabitOnTues
                                                            HabitOnWedSet = habitNdx.HabitOnWed
                                                            HabitOnThursSet = habitNdx.HabitOnThurs
                                                            HabitOnFriSet = habitNdx.HabitOnFri
                                                            HabitOnSatSet = habitNdx.HabitOnSat
                                                            
                                                        }
                                                    } else {}
                                                }
                                            } label: {
                                                HStack {
                                                    //-----------------------------------------------------
                                                    Text(habitNdx.HabitName)
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(habitNdx.HabitGoal) \(habitNdx.HabitUnit)")
                                                    //-----------------------------------------------------
                                                }
                                            }
                                        } else {}
                                    }.onMove(perform: move)
                                    
                                }
                        
                            }
//                            .toolbar {
//                                EditButton()
//                            }
                        }
                    
                    
                    } else {Text("No Habits")}
                }
            }
            
            if DisplayHabitMaker == true {
                
                VStack{
                    Button {
                        DisplayHabitMaker = false
                    } label: {
                        closeButton
                    }.padding()

                    habitBuilderForm
                    
                } // VSTACK
                .frame(width:300,height:700)
                .cornerRadius(10)
                .background(Rectangle()
                    .foregroundColor(.black))
                .cornerRadius(20)
                .shadow(radius: 20)
                
            } else {}
            
        }.onAppear{indexProtocols()}
    }
        
    // ------------------------------------ Spacer
    
    private func updateHabit(habitToEdit: UUID) {
        
        var habitDataIteratorList: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
        
        for ndx in 0..<habitDataIteratorList.count {
            if habitDataIteratorList[ndx].id == habitToEdit {
                habitDataIteratorList[ndx].HabitName = HabitNameSet
                habitDataIteratorList[ndx].HabitGoal = HabitGoalSet
                habitDataIteratorList[ndx].HabitUnit = HabitUnitSet
                habitDataIteratorList[ndx].HabitProtocol = HabitProtocolSet
                habitDataIteratorList[ndx].HabitRepeatValue = HabitRepetitionSet
                habitDataIteratorList[ndx].HabitDescription = HabitDescriptionSet
                habitDataIteratorList[ndx].HabitStartDate = HabitStartDateSet
                habitDataIteratorList[ndx].HabitReward = HabitRewardSet
                habitDataIteratorList[ndx].HabitHasStatus = HabitHasStatusSet
                habitDataIteratorList[ndx].HabitHasCheckbox = HabitHasCheckboxSet
                
                habitDataIteratorList[ndx].HabitUseDow = HabitUseDOWSet
                
                habitDataIteratorList[ndx].HabitOnSun = HabitOnSunSet
                habitDataIteratorList[ndx].HabitOnMon = HabitOnMonSet
                habitDataIteratorList[ndx].HabitOnTues = HabitOnTuesSet
                habitDataIteratorList[ndx].HabitOnWed = HabitOnWedSet
                habitDataIteratorList[ndx].HabitOnThurs = HabitOnThursSet
                habitDataIteratorList[ndx].HabitOnFri = HabitOnFriSet
                habitDataIteratorList[ndx].HabitOnSat = HabitOnSatSet
                
                // Add content for DOW repetition
                
                if habitDataIteratorList[ndx].HabitHasCheckbox == true {
                    habitDataIteratorList[ndx].HabitGoal = 1
                    habitDataIteratorList[ndx].HabitUnit = "units"
                }
            }
        }
        
        UserDefaults.standard.setEncodable(habitDataIteratorList, forKey: "habitList")
        
        habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
    }
    
    
    private func displayNameByUUID (id: UUID) -> String {
        for index in habitData {
            if index.id == id {
                return index.HabitName
            }
        }
        return "None"
    }

    
    private func openHabitBuilder() {
        DisplayHabitMaker = true
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

    private func addItem() {
        
        if HabitHasCheckboxSet == true {
            HabitGoalSet = 1
            HabitUnitSet = "units"
        }
        
        if HabitUseDOWSet == false {
            HabitOnMonSet = false
            HabitOnTuesSet = false
            HabitOnWedSet = false
            HabitOnThursSet = false
            HabitOnFriSet = false
            HabitOnSatSet = false
            HabitOnSunSet = false
        }
        
        if HabitIsSubtaskSet == true && HabitSuperTaskSet != nil {
            for index in 0..<habitData.count {
                if habitData[index].id == HabitSuperTaskSet {
                    habitData[index].HabitHasSubtask = true
                }
            }
            UserDefaults.standard.setEncodable(habitData, forKey: "habitList")
        } else {}
        
            
        let inputHabit:Habit = Habit(HabitName: HabitNameSet,
                                HabitGoal: HabitGoalSet,
                                HabitUnit: HabitUnitSet,
                                HabitProtocol: HabitProtocolSet,
                                HabitStartDate: Calendar.current.startOfDay(for: HabitStartDateSet),
                                HabitRepeatValue: HabitRepetitionSet,
                                HabitDescription: HabitDescriptionSet,
                                HabitReward: Int16(HabitRewardSet),
                                HabitHasStatus: HabitHasStatusSet,
                                HabitHasCheckbox: HabitHasCheckboxSet,
                                HabitIsSubtask: HabitIsSubtaskSet,
                                HabitSuperTask: HabitSuperTaskSet,
                                
                                HabitUseDow: HabitUseDOWSet,
                                     
                                HabitOnSun: HabitOnSunSet,
                                HabitOnMon: HabitOnMonSet,
                                HabitOnTues: HabitOnTuesSet,
                                HabitOnWed: HabitOnWedSet,
                                HabitOnThurs: HabitOnThursSet,
                                HabitOnFri: HabitOnFriSet,
                                HabitOnSat: HabitOnSatSet)
        
        if var outData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") {

            outData.append(inputHabit)
            UserDefaults.standard.setEncodable(outData, forKey: "habitList")
            
        } else {

            let initHabitList:[Habit] = [inputHabit]
            UserDefaults.standard.setEncodable(initHabitList, forKey: "habitList")
        }
        
            
            
        if (daysBetween(start: Calendar.current.startOfDay(for: inputHabit.HabitStartDate),end: Calendar.current.startOfDay(for: Date())) >= 0) && (daysBetween(start:  Calendar.current.startOfDay(for: inputHabit.HabitStartDate),end: Calendar.current.startOfDay(for: Date())) % inputHabit.HabitRepeatValue == 0) {
                                    
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = inputHabit.HabitName
            newItem.goal = inputHabit.HabitGoal
            newItem.unit = inputHabit.HabitUnit
            newItem.whichProtocol = inputHabit.HabitProtocol
            newItem.complete = false
            newItem.reward = inputHabit.HabitReward
            newItem.id = UUID()
            newItem.hasStatus = inputHabit.HabitHasStatus
            newItem.hasCheckbox = inputHabit.HabitHasCheckbox
            newItem.notFloater = true
            
//            newItem.useDow = inputHabit.HabitUseDow
//
//            newItem.rSun = inputHabit.HabitOnSun
//            newItem.rMon = inputHabit.HabitOnMon
//            newItem.rTues = inputHabit.HabitOnTues
//            newItem.rWed = inputHabit.HabitOnWed
//            newItem.rThur = inputHabit.HabitOnThurs
//            newItem.rFri = inputHabit.HabitOnFri
//            newItem.rSat = inputHabit.HabitOnSat
            
        }
            
        
        DisplayHabitMaker = false
        HabitNameSet = ""
        HabitGoalSet = 1
        HabitUnitSet = "units"
        HabitProtocolSet = "Daily"
        HabitDescriptionSet = ""
        HabitHasStatusSet = false
        HabitRewardSet = 1
        HabitStartDateSet = Date()
        HabitHasCheckboxSet = true
        HabitIsSubtaskSet = false
        HabitSuperTaskSet = nil
        HabitHasSubTaskSet = false
        
        HabitOnMonSet = false
        HabitOnTuesSet = false
        HabitOnWedSet = false
        HabitOnThursSet = false
        HabitOnFriSet = false
        HabitOnSatSet = false
        HabitOnSunSet = false
        
        habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
        
        indexProtocols()

    }

    private func move(from source: IndexSet, to destination: Int) {
        habitData.move(fromOffsets: source, toOffset: destination)
        UserDefaults.standard.setEncodable(habitData, forKey: "habitList")
        habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
    }

}

//#Preview {
//    HabitBuilderView(selectedTab: .HUB)
//}
