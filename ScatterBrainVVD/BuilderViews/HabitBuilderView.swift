//
//  HabitBuilderView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import CoreData

struct HabitBuilderView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.order, ascending: true)],
        animation: .default)
    private var habitData: FetchedResults<HabitItem>
    
    @Environment(\.managedObjectContext) private var viewContext
        
    @State var DisplayHabitMaker: Bool = false
    @State var DisplayHabitEditor: Bool = false
    
    @State var HabitNameSet: String = ""
    @State var HabitGoalSet: Int16 = 1
    @State var HabitProtocolSet: String = "Daily"
    @State var HabitUnitSet: String = "units"
    @State var HabitRepetitionSet: Int16 = 1
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
                Button {addItem(viewContext: viewContext)} label: {Text("Save Habit")}
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
                
//                if let listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") {

                if habitData.isEmpty != true {
                    
                        NavigationView {
                            
                            List {
                                if displayByProtocol == true {
                                    ForEach(listOfProtocols!) { index in

                                        Text(index.ProtocolName)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .padding(.top)

                                        ForEach(habitData) { habitNdx in

                                            if habitNdx.whichProtocol == index.ProtocolName && habitNdx.isSubtask == false {

                                                NavigationLink{
                                                    ZStack{
                                                        VStack {
                                                                                                           
                                                            List{
                                                                Text(habitNdx.name ?? "")
                                                                    .font(.title)
                                                                    .padding()
                                                                Text("Item is part of protocol \(habitNdx.whichProtocol ?? "").")
                                                                Text("Item start date: \(habitNdx.startDate ?? Date(), formatter: itemFormatter)" )
                                                                Text("Item goal value: \(habitNdx.goal) \(habitNdx.unit ?? "")" )
                                                                
                                                                if habitNdx.useDow == true {
                                                                    
                                                                    if habitNdx.onSun == true {Text("Item repeats on Sunday")} else {}
                                                                    if habitNdx.onMon == true {Text("Item repeats on Monday")} else {}
                                                                    if habitNdx.onTues == true {Text("Item repeats on Tuesday")} else {}
                                                                    if habitNdx.onWed == true {Text("Item repeats on Wednesday")} else {}
                                                                    if habitNdx.onThurs == true {Text("Item repeats on Thursday")} else {}
                                                                    if habitNdx.onFri == true {Text("Item repeats on Friday")} else {}
                                                                    if habitNdx.onSat == true {Text("Item repeats on Saturday")} else {}

                                                                } else {
                                                                    Text("Item repeats every \(habitNdx.repeatValue) days." )
                                                                }
                                                                
                                                                
                                                                
                                                                
                                                                Text("Item Description: \n\n \(habitNdx.descript ?? "")" )
                                                                
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
                                                            Button{deleteEntityHabit(withUUID: habitNdx.id ?? UUID(), viewContext: viewContext)} label: {
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
                                                                        updateHabit(habitToEdit: habitNdx)
                                                                        //------------------------------------
                                                                        DisplayHabitEditor = false
                                                                        indexProtocols(viewContext: viewContext)
                                                                        listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")
                                                                        
                                                                    } label: {Text("Save Habit")}
                                                                }
                                                            }
                                                            .onAppear{

                                                                //Keep commented out for now, possibly problematic

//
                                                        HabitNameSet = habitNdx.name ?? ""
                                                        HabitGoalSet = habitNdx.goal
                                                        HabitUnitSet = habitNdx.unit ?? "unit"
                                                        HabitProtocolSet = habitNdx.whichProtocol ?? "Daily"
                                                        HabitRepetitionSet = habitNdx.repeatValue
                                                        HabitDescriptionSet = habitNdx.descript ?? ""
                                                        HabitStartDateSet = habitNdx.startDate ?? Date()
                                                        HabitRewardSet = habitNdx.reward
                                                        HabitHasCheckboxSet = habitNdx.hasCheckbox
                                                        HabitHasStatusSet = habitNdx.hasStatus
//
                                                        HabitUseDOWSet = habitNdx.useDow
//
                                                        HabitOnSunSet = habitNdx.onSun
                                                        HabitOnMonSet = habitNdx.onMon
                                                        HabitOnTuesSet = habitNdx.onTues
                                                        HabitOnWedSet = habitNdx.onWed
                                                        HabitOnThursSet = habitNdx.onThurs
                                                        HabitOnFriSet = habitNdx.onFri
                                                        HabitOnSatSet = habitNdx.onSat//
//
                                                            }

                                                        } else {}
                                                    }
                                                } label: {
                                                    HStack {
                                                        //-----------------------------------------------------
                                                        Text(habitNdx.name ?? "")

                                                        Spacer()

                                                        Text("\(habitNdx.goal) \(habitNdx.unit ?? "")")
                                                        //-----------------------------------------------------
                                                    }
                                                }
                                            } else {}
                                        }.onMove(perform: move)
                                    }
                        
                                } else {
                                    
                                    ForEach(habitData) { habitNdx in
                                        
                                        if habitNdx.isSubtask == false {
                                            
                                            NavigationLink{
                                                ZStack{
                                                    VStack {
                                                                                                       
                                                        List{
                                                            Text(habitNdx.name ?? "")
                                                                .font(.title)
                                                                .padding()
                                                            Text("Item is part of protocol \(habitNdx.whichProtocol ?? "").")
                                                            Text("Item start date: \(habitNdx.startDate ?? Date(), formatter: itemFormatter)" )
                                                            Text("Item goal value: \(habitNdx.goal) \(habitNdx.unit ?? "")" )
                                                            
                                                            if habitNdx.useDow == true {
                                                                
                                                                if habitNdx.onSun == true {Text("Item repeats on Sunday")} else {}
                                                                if habitNdx.onMon == true {Text("Item repeats on Monday")} else {}
                                                                if habitNdx.onTues == true {Text("Item repeats on Tuesday")} else {}
                                                                if habitNdx.onWed == true {Text("Item repeats on Wednesday")} else {}
                                                                if habitNdx.onThurs == true {Text("Item repeats on Thursday")} else {}
                                                                if habitNdx.onFri == true {Text("Item repeats on Friday")} else {}
                                                                if habitNdx.onSat == true {Text("Item repeats on Saturday")} else {}

                                                            } else {
                                                                Text("Item repeats every \(habitNdx.repeatValue) days." )
                                                            }
                                                            
                                                            
                                                            
                                                            
                                                            Text("Item Description: \n\n \(habitNdx.descript ?? "")" )
                                                            
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
                                                        Button{deleteEntityHabit(withUUID: habitNdx.id ?? UUID(), viewContext: viewContext)} label: {
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
                                                                    //Keep commented out for now, possibly problematic
                                                                    updateHabit(habitToEdit: habitNdx)
                                                                    //------------------------------------
                                                                    DisplayHabitEditor = false
                                                                    indexProtocols(viewContext: viewContext)
                                                                    listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")
                                                                    
                                                                    //crap commit
                                                                } label: {Text("Save Habit")}
                                                            }
                                                        }
                                                        .onAppear{
                                                            
                                                            
                                                            HabitNameSet = habitNdx.name ?? ""
                                                            HabitGoalSet = habitNdx.goal
                                                            HabitUnitSet = habitNdx.unit ?? "unit"
                                                            HabitProtocolSet = habitNdx.whichProtocol ?? "Daily"
                                                            HabitRepetitionSet = habitNdx.repeatValue
                                                            HabitDescriptionSet = habitNdx.descript ?? ""
                                                            HabitStartDateSet = habitNdx.startDate ?? Date()
                                                            HabitRewardSet = habitNdx.reward
                                                            HabitHasCheckboxSet = habitNdx.hasCheckbox
                                                            HabitHasStatusSet = habitNdx.hasStatus
//                                                            
                                                            HabitUseDOWSet = habitNdx.useDow
//                                                            
                                                            HabitOnSunSet = habitNdx.onSun
                                                            HabitOnMonSet = habitNdx.onMon
                                                            HabitOnTuesSet = habitNdx.onTues
                                                            HabitOnWedSet = habitNdx.onWed
                                                            HabitOnThursSet = habitNdx.onThurs
                                                            HabitOnFriSet = habitNdx.onFri
                                                            HabitOnSatSet = habitNdx.onSat
                                                            
                                                        }
                                                    } else {}
                                                }// end zstack
                                                .onAppear {DisplayHabitEditor = false}
                                            } label: {
                                                HStack {
                                                    //-----------------------------------------------------
                                                    Text(habitNdx.name ?? "")
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(habitNdx.goal) \(habitNdx.unit ?? "")")
                                                    //-----------------------------------------------------
                                                }
                                            }
                                        } else {}
                                    }.onMove(perform: move)
                                } // END ELSE (DISPLAY BY PROTOCOL)
                            }
                        }
                    
                    
                    } else {Text("No Habits")}
//                } // END PROT LIST CONDITIONAL
                
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
            
        }.onAppear{indexProtocols(viewContext: viewContext)}
    }
        
    // ------------------------------------ Spacer
    
    private func updateHabit(habitToEdit: HabitItem) {

        habitToEdit.name = HabitNameSet
        habitToEdit.goal = HabitGoalSet
        habitToEdit.unit = HabitUnitSet
        habitToEdit.whichProtocol = HabitProtocolSet
        habitToEdit.repeatValue = HabitRepetitionSet
        habitToEdit.descript = HabitDescriptionSet
        habitToEdit.startDate = HabitStartDateSet
        habitToEdit.reward = HabitRewardSet
        habitToEdit.hasStatus = HabitHasStatusSet
        habitToEdit.hasCheckbox = HabitHasCheckboxSet
                
        habitToEdit.useDow = HabitUseDOWSet
                
        habitToEdit.onSun = HabitOnSunSet
        habitToEdit.onMon = HabitOnMonSet
        habitToEdit.onTues = HabitOnTuesSet
        habitToEdit.onWed = HabitOnWedSet
        habitToEdit.onThurs = HabitOnThursSet
        habitToEdit.onFri = HabitOnFriSet
        habitToEdit.onSat = HabitOnSatSet
                                
        if habitToEdit.hasCheckbox == true {
            habitToEdit.goal = 1
            habitToEdit.unit = "units"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    

    private func addItem(viewContext: NSManagedObjectContext) {
        
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
        
//        if HabitIsSubtaskSet == true && HabitSuperTaskSet != nil {
//            for index in 0..<habitData.count {
//                if habitData[index].id == HabitSuperTaskSet {
////                    habitData[index].hasSubtask = true
//                }
//            }
////            UserDefaults.standard.setEncodable(habitData, forKey: "habitList")
//        } else {}
        
        let newHabitItem = HabitItem(context: viewContext)
        
        newHabitItem.id = UUID()
        
        newHabitItem.name = HabitNameSet
        newHabitItem.goal = HabitGoalSet
        newHabitItem.unit = HabitUnitSet
        newHabitItem.whichProtocol = HabitProtocolSet
        newHabitItem.repeatValue = HabitRepetitionSet
        newHabitItem.descript = HabitDescriptionSet
        newHabitItem.startDate = Calendar.current.startOfDay(for: HabitStartDateSet)
        newHabitItem.reward = HabitRewardSet
        newHabitItem.hasStatus = HabitHasStatusSet
        newHabitItem.hasCheckbox = HabitHasCheckboxSet
                
        newHabitItem.useDow = HabitUseDOWSet
                
        newHabitItem.onSun = HabitOnSunSet
        newHabitItem.onMon = HabitOnMonSet
        newHabitItem.onTues = HabitOnTuesSet
        newHabitItem.onWed = HabitOnWedSet
        newHabitItem.onThurs = HabitOnThursSet
        newHabitItem.onFri = HabitOnFriSet
        newHabitItem.onSat = HabitOnSatSet
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        
        //Code To shove new habit on creation if the repetition matches properly
        
        if newHabitItem.useDow == false {
            
            if (daysBetween(start: Calendar.current.startOfDay(for: newHabitItem.startDate ?? Date()),end: Calendar.current.startOfDay(for: Date())) >= 0)
                && (daysBetween(start:  Calendar.current.startOfDay(for: newHabitItem.startDate ?? Date()),end: Calendar.current.startOfDay(for: Date())) % Int(newHabitItem.repeatValue) == 0) {
                                        
                let newItem = Item(context: viewContext)
                newItem.timestamp = Date()
                newItem.name = newHabitItem.name
                newItem.goal = newHabitItem.goal
                newItem.unit = newHabitItem.unit
                newItem.whichProtocol = newHabitItem.whichProtocol
                newItem.complete = false
                newItem.reward = newHabitItem.reward
                newItem.id = UUID()
                newItem.hasStatus = newHabitItem.hasStatus
                newItem.hasCheckbox = newHabitItem.hasCheckbox
                newItem.notFloater = true

            }

        } else {
            
            if  (newHabitItem.onMon == true && dayOfWeek == "Monday") ||
                (newHabitItem.onTues == true && dayOfWeek == "Tuesday") ||
                (newHabitItem.onWed == true && dayOfWeek == "Wednesday") ||
                (newHabitItem.onThurs == true && dayOfWeek == "Thursday") ||
                (newHabitItem.onFri == true && dayOfWeek == "Friday") ||
                (newHabitItem.onSat == true && dayOfWeek == "Saturday") ||
                (newHabitItem.onSun == true && dayOfWeek == "Sunday")
            {
                    
                let newItem = Item(context: viewContext)
                newItem.timestamp = Date()
                newItem.name = newHabitItem.name
                newItem.goal = newHabitItem.goal
                newItem.unit = newHabitItem.unit
                newItem.whichProtocol = newHabitItem.whichProtocol
                newItem.complete = false
                newItem.reward = newHabitItem.reward
                newItem.id = UUID()
                newItem.hasStatus = newHabitItem.hasStatus
                newItem.hasCheckbox = newHabitItem.hasCheckbox
                newItem.notFloater = true
      
            }
            
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
                
        indexProtocols(viewContext: viewContext)

    }

    private func move(from source: IndexSet, to destination: Int) {
        
            var updates: [(HabitItem, Int32)] = []
            var reorderedItems = Array(habitData)
            
            reorderedItems.move(fromOffsets: source, toOffset: destination)
            
            for (index, item) in reorderedItems.enumerated() {
                if item.order != Int32(index) {
                    updates.append((item, Int32(index)))
                }
            }
            
            for (item, newOrder) in updates {
                item.order = newOrder
            }
            
        saveViewContext(viewContext: viewContext)
            
    }
}

//#Preview {
//    HabitBuilderView()
//}
