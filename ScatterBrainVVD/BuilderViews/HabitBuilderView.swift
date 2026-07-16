//
//  HabitBuilderView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import SwiftData

struct HabitBuilderView: View {

    @Query(sort: \habItem.order)
    var its: [habItem]

    @Environment(\.modelContext) private var modelContext
        
    @State var DisplayHabitMaker: Bool = false
    @State var DisplayHabitEditor: Bool = false
    @State var displayProtocolLibrary: Bool = false
    
    @State var HabitNameSet: String = ""
    @State var HabitGoalSet: Int16 = 1
    @State var HabitProtocolSet: String = "Daily"
    @State var HabitUnitSet: String = "Units"
    @State var HabitRepetitionSet: Int16 = 1
    @State var HabitDescriptionSet: String = ""
    @State var HabitHasStatusSet: Bool = false
    @State var HabitRewardSet: Int16 = 1
    @State var HabitStartDateSet: Date = Date()
    @State var HabitHasCheckboxSet: Bool = true
    @State var HabitHasSubTaskSet: Bool = false
    @State var HabitSuperTaskSet: UUID? = nil
    @State var HabitTimeRegionSet: String = "None"
    
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
    
    @State var listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")
    
//    private var habLister: some View {
//        ForEach($habitData){ superTaskHabit in
//            
//            if superTaskHabit.isSubtask == false {
//                Button{
//                    HabitSuperTaskSet = superTaskHabit.id
//                } label: {
//                    Text(superTaskHabit.HabitName)
//                }
//            }
//        }
//    }
    
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
            
            Toggle("Include Subhabits?", isOn: $HabitHasSubTaskSet)
            if HabitHasSubTaskSet == true {
                
                Text("Subhabit Creator View")
                
            } else {}
            
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
                Section(header: Text("Time of day (narrows reminder notifications):")) {
                    Picker("Time of day", selection: $HabitTimeRegionSet) {
                        ForEach(timeRegionOptions, id: \.self) { region in
                            Text(region)
                        }
                    }
                }
                Section(header: Text("Habit Reward (Points for completion)")) {
                    TextField("", value: $HabitRewardSet, format: .number)
                }
                Toggle("Include status update", isOn: $HabitHasStatusSet)
            
//            } // END SUBTASKER BRACKET
            
            
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
                    Button {
                        displayProtocolLibrary = true
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .padding(.bottom)
                    }

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
                
//                if let listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") {

                if its.isEmpty != true {
                    
                        NavigationView {
                            
                            List {
                                if displayByProtocol == true {
                                    ForEach(listOfProtocols!) { index in

                                        Text(index.ProtocolName)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .padding(.top)

                                        ForEach(its) { habitNdx in

                                            if habitNdx.whichProtocol == index.ProtocolName {

                                                NavigationLink{
                                                    ZStack{
                                                        VStack {
                                                                                                           
                                                            List{
                                                                Text(habitNdx.name)
                                                                    .font(.title)
                                                                    .padding()
                                                                Text("Item is part of protocol \(habitNdx.whichProtocol).")
                                                                Text("Item start date: \(habitNdx.startDate, formatter: itemFormatter)" )
                                                                Text("Item goal value: \(habitNdx.goal) \(habitNdx.unit)" )
                                                                
                                                                if habitNdx.useDow == true {
                                                                    
                                                                    if habitNdx.dow.onSun == true {Text("Item repeats on Sunday")} else {}
                                                                    if habitNdx.dow.onMon == true {Text("Item repeats on Monday")} else {}
                                                                    if habitNdx.dow.onTues == true {Text("Item repeats on Tuesday")} else {}
                                                                    if habitNdx.dow.onWed == true {Text("Item repeats on Wednesday")} else {}
                                                                    if habitNdx.dow.onThurs == true {Text("Item repeats on Thursday")} else {}
                                                                    if habitNdx.dow.onFri == true {Text("Item repeats on Friday")} else {}
                                                                    if habitNdx.dow.onSat == true {Text("Item repeats on Saturday")} else {}

                                                                } else {
                                                                    Text("Item repeats every \(habitNdx.repeatValue) days." )
                                                                }
                                                                
                                                                
                                                                
                                                                
                                                                Text("Item Description: \n\n \(habitNdx.descript)" )
                                                                
    //                                                            if habitNdx.hasSubtask == true {
    //                                                                Text("Subhabits:")
    //                                                                ForEach(habitData){ indexr in
    //                                                                    if indexr.superTask == habitNdx.id {
    //                                                                        Text(indexr.name)
    //                                                                    }
    //                                                                }
    //                                                            }
                                                                
                                                            }
                                                                                                                    
                                                            Button{DisplayHabitEditor = true} label: {
                                                                Text("Edit habit")
                                                            }
                                                            Button{modelContext.delete(habitNdx); try? modelContext.save()} label: {
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
                                                                Section(header: Text("Time of day (narrows reminder notifications):")) {
                                                                    Picker("Time of day", selection: $HabitTimeRegionSet) {
                                                                        ForEach(timeRegionOptions, id: \.self) { region in
                                                                            Text(region)
                                                                        }
                                                                    }
                                                                }
                                                                Section(header: Text("Habit Reward (Points for completion)")) {
                                                                    TextField("", value: $HabitRewardSet, format: .number)
                                                                }
                                                                Toggle("Include status update", isOn: $HabitHasStatusSet)
                                                                Section {
                                                                    Button {
                                                                        //------------------------------------
                                                                        updateHabit(habitToEdit: habitNdx)
                                                                        //------------------------------------
                                                                        DisplayHabitEditor = false
                                                                        indexProtocols(modelContext: modelContext)
                                                                        listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")
                                                                        
                                                                    } label: {Text("Save Habit")}
                                                                }
                                                            }
                                                            .onAppear{

                                                                //Keep commented out for now, possibly problematic

//
                                                        HabitNameSet = habitNdx.name
                                                        HabitGoalSet = Int16(habitNdx.goal)
                                                        HabitUnitSet = habitNdx.unit
                                                        HabitProtocolSet = habitNdx.whichProtocol
                                                        HabitRepetitionSet = Int16(habitNdx.repeatValue)
                                                        HabitDescriptionSet = habitNdx.descript
                                                        HabitStartDateSet = habitNdx.startDate
                                                        HabitRewardSet = Int16(habitNdx.reward)
                                                        HabitHasCheckboxSet = habitNdx.hasCheckbox
                                                        HabitHasStatusSet = habitNdx.hasStatus
                                                        HabitTimeRegionSet = habitNdx.timeRegion
//
                                                        HabitUseDOWSet = habitNdx.useDow
//
                                                        HabitOnSunSet = habitNdx.dow.onSun
                                                        HabitOnMonSet = habitNdx.dow.onMon
                                                        HabitOnTuesSet = habitNdx.dow.onTues
                                                        HabitOnWedSet = habitNdx.dow.onWed
                                                        HabitOnThursSet = habitNdx.dow.onThurs
                                                        HabitOnFriSet = habitNdx.dow.onFri
                                                        HabitOnSatSet = habitNdx.dow.onSat//
//
                                                            }

                                                        } else {}
                                                    }
                                                } label: {
                                                    HStack {
                                                        //-----------------------------------------------------
                                                        Text(habitNdx.name)

                                                        Spacer()

                                                        Text("\(habitNdx.goal) \(habitNdx.unit)")
                                                        //-----------------------------------------------------
                                                    }
                                                }
                                            } else {}
                                        }.onMove(perform: move)
                                    }
                        
                                } else {
                                    
                                    ForEach(its) { habitNdx in
                                        
                                            
                                            NavigationLink{
                                                ZStack{
                                                    VStack {
                                                                                                       
                                                        List{
                                                            Text(habitNdx.name)
                                                                .font(.title)
                                                                .padding()
                                                            Text("Item is part of protocol \(habitNdx.whichProtocol).")
                                                            Text("Item start date: \(habitNdx.startDate, formatter: itemFormatter)" )
                                                            Text("Item goal value: \(habitNdx.goal) \(habitNdx.unit)" )
                                                            
                                                            if habitNdx.useDow == true {
                                                                
                                                                if habitNdx.dow.onSun == true {Text("Item repeats on Sunday")} else {}
                                                                if habitNdx.dow.onMon == true {Text("Item repeats on Monday")} else {}
                                                                if habitNdx.dow.onTues == true {Text("Item repeats on Tuesday")} else {}
                                                                if habitNdx.dow.onWed == true {Text("Item repeats on Wednesday")} else {}
                                                                if habitNdx.dow.onThurs == true {Text("Item repeats on Thursday")} else {}
                                                                if habitNdx.dow.onFri == true {Text("Item repeats on Friday")} else {}
                                                                if habitNdx.dow.onSat == true {Text("Item repeats on Saturday")} else {}

                                                            } else {
                                                                Text("Item repeats every \(habitNdx.repeatValue) days." )
                                                            }
                                                            
                                                            
                                                            
                                                            
                                                            Text("Item Description: \n\n \(habitNdx.descript)" )
                                                            
//                                                            if habitNdx.hasSubtask == true {
//                                                                Text("Subhabits:")
//                                                                ForEach(habitData){ indexr in
//                                                                    if indexr.superTask == habitNdx.id {
//                                                                        Text(indexr.name)
//                                                                    }
//                                                                }
//                                                            }
                                                            
                                                        }
                                                                                                                
                                                        Button{DisplayHabitEditor = true} label: {
                                                            Text("Edit habit")
                                                        }
                                                        Button{modelContext.delete(habitNdx); try? modelContext.save()} label: {
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
                                                            Section(header: Text("Time of day (narrows reminder notifications):")) {
                                                                Picker("Time of day", selection: $HabitTimeRegionSet) {
                                                                    ForEach(timeRegionOptions, id: \.self) { region in
                                                                        Text(region)
                                                                    }
                                                                }
                                                            }
                                                            Section(header: Text("Habit Reward (Points for completion)")) {
                                                                TextField("", value: $HabitRewardSet, format: .number)
                                                            }
                                                            Toggle("Include status update", isOn: $HabitHasStatusSet)
                                                            Section {
                                                                Button {
                                                                    //------------------------------------
                                                                    //Keep commented out for now, possibly problematic
                                                                    updateHabit(habitToEdit: habitNdx)
                                                                    //------------------------------------
                                                                    DisplayHabitEditor = false
                                                                    indexProtocols(modelContext: modelContext)
                                                                    listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")

                                                                    //crap commit
                                                                } label: {Text("Save Habit")}
                                                            }
                                                        }
                                                        .onAppear{
                                                            
                                                            
                                                            HabitNameSet = habitNdx.name
                                                            HabitGoalSet = Int16(habitNdx.goal)
                                                            HabitUnitSet = habitNdx.unit
                                                            HabitProtocolSet = habitNdx.whichProtocol
                                                            HabitRepetitionSet = Int16(habitNdx.repeatValue)
                                                            HabitDescriptionSet = habitNdx.descript
                                                            HabitStartDateSet = habitNdx.startDate
                                                            HabitRewardSet = Int16(habitNdx.reward)
                                                            HabitHasCheckboxSet = habitNdx.hasCheckbox
                                                            HabitHasStatusSet = habitNdx.hasStatus
                                                            HabitTimeRegionSet = habitNdx.timeRegion
//
                                                            HabitUseDOWSet = habitNdx.useDow
//                                                            
                                                            HabitOnSunSet = habitNdx.dow.onSun
                                                            HabitOnMonSet = habitNdx.dow.onMon
                                                            HabitOnTuesSet = habitNdx.dow.onTues
                                                            HabitOnWedSet = habitNdx.dow.onWed
                                                            HabitOnThursSet = habitNdx.dow.onThurs
                                                            HabitOnFriSet = habitNdx.dow.onFri
                                                            HabitOnSatSet = habitNdx.dow.onSat
                                                            
                                                        }
                                                    } else {}
                                                }// end zstack
                                                .onAppear {DisplayHabitEditor = false}
                                            } label: {
                                                HStack {
                                                    //-----------------------------------------------------
                                                    Text(habitNdx.name)
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(habitNdx.goal) \(habitNdx.unit)")
                                                    //-----------------------------------------------------
                                                }
                                            }
                                    }.onMove(perform: move)
                                } // END ELSE (DISPLAY BY PROTOCOL)
                            }
                        }
                    
                    
                    } else {Text("No Habits")}
//                } // END PROT LIST CONDITIONAL

                Button {
                    generateTestHabitData(modelContext: modelContext)
                } label: {
                    Text("generate test habits")
                }
                .foregroundColor(ForeColor)
                .padding(.bottom)

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

            if displayProtocolLibrary == true {
                ProtocolLibraryModal(isPresented: $displayProtocolLibrary, onIncorporate: {
                    listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")
                })
            } else {}

        }.onAppear{indexProtocols(modelContext: modelContext)}
    }
        
    // ------------------------------------ Spacer
    
    private func updateHabit(habitToEdit: habItem) {

        habitToEdit.name = HabitNameSet
        habitToEdit.goal = Int(HabitGoalSet)
        habitToEdit.unit = HabitUnitSet
        habitToEdit.whichProtocol = HabitProtocolSet
        habitToEdit.repeatValue = Int(HabitRepetitionSet)
        habitToEdit.descript = HabitDescriptionSet
        habitToEdit.startDate = HabitStartDateSet
        habitToEdit.reward = Int(HabitRewardSet)
        habitToEdit.hasStatus = HabitHasStatusSet
        habitToEdit.hasCheckbox = HabitHasCheckboxSet
        habitToEdit.timeRegion = HabitTimeRegionSet

        habitToEdit.useDow = HabitUseDOWSet

        habitToEdit.dow.onSun = HabitOnSunSet
        habitToEdit.dow.onMon = HabitOnMonSet
        habitToEdit.dow.onTues = HabitOnTuesSet
        habitToEdit.dow.onWed = HabitOnWedSet
        habitToEdit.dow.onThurs = HabitOnThursSet
        habitToEdit.dow.onFri = HabitOnFriSet
        habitToEdit.dow.onSat = HabitOnSatSet

        if habitToEdit.hasCheckbox == true {
            habitToEdit.goal = 1
            habitToEdit.unit = "units"
        }

        try? modelContext.save()
    }
    

    private func addItem() {
        
        let date = Date()
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "EEEE"
        let dayOfWeek = dformatter.string(from: date)
        
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
        

        
        let newHabitItem = habItem(descript: HabitDescriptionSet,
                                   goal: Int(HabitGoalSet),
                                   hasCheckbox: HabitHasCheckboxSet,
                                   hasStatus: HabitHasStatusSet,
                                   hasSubtask: HabitHasSubTaskSet,
                                   id: UUID(),
                                   name: HabitNameSet,
                                   order: its.count,
                                   repeatValue: Int(HabitRepetitionSet),
                                   reward: Int(HabitRewardSet),
                                   startDate: Calendar.current.startOfDay(for: HabitStartDateSet),
                                   superTask: HabitSuperTaskSet,
                                   timeRegion: HabitTimeRegionSet,
                                   unit: HabitUnitSet,
                                   useDow: HabitUseDOWSet,
                                   whichProtocol: HabitProtocolSet)

        newHabitItem.dow = dow(onSun: HabitOnSunSet,
                               onMon: HabitOnMonSet,
                               onTues: HabitOnTuesSet,
                               onWed: HabitOnWedSet,
                               onThurs: HabitOnThursSet,
                               onFri: HabitOnFriSet,
                               onSat: HabitOnSatSet)

        modelContext.insert(newHabitItem)
        try? modelContext.save()
        
        
        //Code To shove new habit on creation if the repetition matches properly
        
        if newHabitItem.useDow == false {

            if (daysBetween(start: Calendar.current.startOfDay(for: newHabitItem.startDate),end: Calendar.current.startOfDay(for: Date())) >= 0)
                && (daysBetween(start:  Calendar.current.startOfDay(for: newHabitItem.startDate),end: Calendar.current.startOfDay(for: Date())) % newHabitItem.repeatValue == 0) {

                modelContext.insert(listItem(from: newHabitItem, timestamp: Date()))

            }

        } else {

            if  (newHabitItem.dow.onMon == true && dayOfWeek == "Monday") ||
                (newHabitItem.dow.onTues == true && dayOfWeek == "Tuesday") ||
                (newHabitItem.dow.onWed == true && dayOfWeek == "Wednesday") ||
                (newHabitItem.dow.onThurs == true && dayOfWeek == "Thursday") ||
                (newHabitItem.dow.onFri == true && dayOfWeek == "Friday") ||
                (newHabitItem.dow.onSat == true && dayOfWeek == "Saturday") ||
                (newHabitItem.dow.onSun == true && dayOfWeek == "Sunday")
            {

                modelContext.insert(listItem(from: newHabitItem, timestamp: Date()))

            }

        }

        saveContext(modelContext: modelContext)

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
        HabitSuperTaskSet = nil
        HabitHasSubTaskSet = false
        HabitTimeRegionSet = "None"
        
        HabitOnMonSet = false
        HabitOnTuesSet = false
        HabitOnWedSet = false
        HabitOnThursSet = false
        HabitOnFriSet = false
        HabitOnSatSet = false
        HabitOnSunSet = false

        indexProtocols(modelContext: modelContext)

    }

    private func move(from source: IndexSet, to destination: Int) {

            var updates: [(habItem, Int)] = []
            var reorderedItems = Array(its)

            reorderedItems.move(fromOffsets: source, toOffset: destination)

            for (index, item) in reorderedItems.enumerated() {
                if item.order != index {
                    updates.append((item, index))
                }
            }

            for (item, newOrder) in updates {
                item.order = newOrder
            }

        try? modelContext.save()

    }
}

#Preview {
    HabitBuilderView()
}
