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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
        
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
    @State var HabitSubhabitsSet: [String] = []
    @State var HabitSuperTaskSet: UUID? = nil
    @State var HabitTimeRegionSet: String = "None"
    @State var HabitColorSet: String = "Default"
    
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
    
    // Pushed habit detail pages; emptied to pop back to the list after a removal
    @State private var path: [habItem] = []
    @State private var confirmRemove: Bool = false

    private enum Tracking { case checkbox, count, steps }

    // The segmented Tracking control is a view onto the two stored flags
    private var trackingSelection: Binding<Tracking> {
        Binding(
            get: { HabitHasSubTaskSet ? .steps : (HabitHasCheckboxSet ? .checkbox : .count) },
            set: { choice in
                switch choice {
                case .checkbox:
                    HabitHasSubTaskSet = false
                    HabitHasCheckboxSet = true
                case .count:
                    HabitHasSubTaskSet = false
                    HabitHasCheckboxSet = false
                case .steps:
                    HabitHasSubTaskSet = true
                }
            })
    }

    @ViewBuilder
    private var subhabitEditor: some View {
        ForEach(HabitSubhabitsSet.indices, id: \.self) { ndx in
            HStack {
                TextField("Step name", text: Binding(
                    get: { ndx < HabitSubhabitsSet.count ? HabitSubhabitsSet[ndx] : "" },
                    set: { if ndx < HabitSubhabitsSet.count { HabitSubhabitsSet[ndx] = $0 } }))
                Button { HabitSubhabitsSet.remove(at: ndx) } label: {
                    Image(systemName: "minus.circle")
                        .foregroundStyle(Theme.destructive)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Remove step")
            }
        }
        Button { HabitSubhabitsSet.append("") } label: { Label("Add step", systemImage: "plus") }
    }

    private var habitBuilderForm: some View {

        Form {
            Section {
                TextField("Habit name", text: $HabitNameSet)
            } header: {
                SectionLabel("Name")
            }
            .listRowBackground(Theme.surface)

            Section {
                ColourSwatchRow(selection: $HabitColorSet)
                    .listRowInsets(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
            } header: {
                SectionLabel("Colour")
            }
            .listRowBackground(Theme.surface)

            Section {
                Picker("Tracking", selection: trackingSelection) {
                    Text("Checkbox").tag(Tracking.checkbox)
                    Text("Count").tag(Tracking.count)
                    Text("Steps").tag(Tracking.steps)
                }
                .pickerStyle(.segmented)

                if (HabitHasCheckboxSet || HabitHasSubTaskSet) == false {
                    LabeledContent("Goal") {
                        TextField("1", value: $HabitGoalSet, format: .number)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Unit") {
                        TextField("units", text: $HabitUnitSet)
                            .multilineTextAlignment(.trailing)
                    }
                }
                if HabitHasSubTaskSet == true {

                    subhabitEditor

                }
            } header: {
                SectionLabel("Tracking")
            }
            .listRowBackground(Theme.surface)

            ScheduleSection(startDate: $HabitStartDateSet,
                            useDow: $HabitUseDOWSet,
                            interval: $HabitRepetitionSet,
                            days: [$HabitOnSunSet, $HabitOnMonSet, $HabitOnTuesSet, $HabitOnWedSet,
                                   $HabitOnThursSet, $HabitOnFriSet, $HabitOnSatSet])

            Section {
                Picker("Time of day", selection: $HabitTimeRegionSet) {
                    ForEach(timeRegionOptions, id: \.self) { region in
                        Text(region)
                    }
                }
            } footer: {
                Text("Narrows reminder notifications")
            }
            .listRowBackground(Theme.surface)

            Section {
                LabeledContent("Protocol") {
                    TextField("Daily", text: $HabitProtocolSet)
                        .multilineTextAlignment(.trailing)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(Theme.meta)
                        .foregroundStyle(Theme.text2)
                    NotesEditor(text: $HabitDescriptionSet)
                }
            } header: {
                SectionLabel("Details")
            }
            .listRowBackground(Theme.surface)

            Section {
                LabeledContent("Reward") {
                    TextField("1", value: $HabitRewardSet, format: .number)
                        .multilineTextAlignment(.trailing)
                }
            } footer: {
                Text("Points for completing")
            }
            .listRowBackground(Theme.surface)

            Section {
                Toggle("Include status update", isOn: $HabitHasStatusSet)
            }
            .listRowBackground(Theme.surface)
        }
        .daybookForm()
        .onChange(of: HabitHasCheckboxSet) { if HabitHasCheckboxSet { HabitHasSubTaskSet = false } }
        .onChange(of: HabitHasSubTaskSet) { if HabitHasSubTaskSet { HabitHasCheckboxSet = false } }
    }

    // One form for both create and edit; only the title and the Save action differ
    private func habitFormSheet(title: String, onCancel: @escaping () -> Void, onSave: @escaping () -> Void) -> some View {
        NavigationStack {
            habitBuilderForm
                .formSheetToolbar(title: title, onCancel: onCancel, onSave: onSave)
        }
    }

    // The form fields are shared state, so a new habit starts from the defaults rather than
    // from whatever was last edited
    private func resetForm() {
        HabitNameSet = ""
        HabitGoalSet = 1
        HabitProtocolSet = "Daily"
        HabitUnitSet = "Units"
        HabitRepetitionSet = 1
        HabitDescriptionSet = ""
        HabitHasStatusSet = false
        HabitRewardSet = 1
        HabitStartDateSet = Date()
        HabitHasCheckboxSet = true
        HabitHasSubTaskSet = false
        HabitSubhabitsSet = []
        HabitTimeRegionSet = "None"
        HabitColorSet = "Default"

        HabitUseDOWSet = false
        HabitOnMonSet = false
        HabitOnTuesSet = false
        HabitOnWedSet = false
        HabitOnThursSet = false
        HabitOnFriSet = false
        HabitOnSatSet = false
        HabitOnSunSet = false
    }

    private func loadForm(from habitNdx: habItem) {
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
        HabitHasSubTaskSet = habitNdx.hasSubtask
        HabitSubhabitsSet = habitNdx.subhabits
        HabitTimeRegionSet = habitNdx.timeRegion
        HabitColorSet = habitNdx.colorName

        HabitUseDOWSet = habitNdx.useDow

        HabitOnSunSet = habitNdx.dow.onSun
        HabitOnMonSet = habitNdx.dow.onMon
        HabitOnTuesSet = habitNdx.dow.onTues
        HabitOnWedSet = habitNdx.dow.onWed
        HabitOnThursSet = habitNdx.dow.onThurs
        HabitOnFriSet = habitNdx.dow.onFri
        HabitOnSatSet = habitNdx.dow.onSat
    }

    // -----------------------------------------------
    //                  LIST ROW + DETAIL
    // ----------------------------------------------

    private func habitRow(_ habitNdx: habItem) -> some View {

        NavigationLink(value: habitNdx) {
            HStack(spacing: 12) {
                //-----------------------------------------------------
                Circle()
                    .fill(habitColor(habitNdx.colorName))
                    .frame(width: 10, height: 10)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(habitNdx.name)
                        .font(Theme.body)
                        .foregroundStyle(Theme.text1)
                        .lineLimit(3)
                    Text(rowMeta(habitNdx))
                        .font(Theme.meta)
                        .foregroundStyle(Theme.text2)

                    // At accessibility sizes the trailing value moves under the name
                    if habitNdx.hasCheckbox == false && dynamicTypeSize.isAccessibilitySize {
                        Text("\(habitNdx.goal) \(habitNdx.unit)")
                            .font(Theme.value)
                            .foregroundStyle(Theme.text2)
                    }
                }

                Spacer(minLength: 0)

                if habitNdx.hasCheckbox == false && dynamicTypeSize.isAccessibilitySize == false {
                    Text("\(habitNdx.goal) \(habitNdx.unit)")
                        .font(Theme.value)
                        .foregroundStyle(Theme.text2)
                }
                //-----------------------------------------------------
            }
            .frame(minHeight: 44)
        }
        .listRowBackground(Theme.surface)
        .listRowSeparatorTint(Theme.separator)
    }

    private func rowMeta(_ habitNdx: habItem) -> String {
        var parts = [scheduleSummary(useDow: habitNdx.useDow, repeatValue: habitNdx.repeatValue, dow: habitNdx.dow, short: true)]
        if habitNdx.timeRegion != "" && habitNdx.timeRegion != "None" { parts.append(habitNdx.timeRegion) }
        return parts.joined(separator: " · ")
    }

    private func habitDetail(_ habitNdx: habItem) -> some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text(habitNdx.name)
                    .font(Theme.detailTitle)
                    .foregroundStyle(habitColor(habitNdx.colorName))
                    .accessibilityAddTraits(.isHeader)

                RowCard {
                    CardRow(label: "Protocol", value: habitNdx.whichProtocol)
                    CardRow(label: "Starts", value: habitNdx.startDate.formatted(date: .abbreviated, time: .omitted))
                    if habitNdx.subhabits.isEmpty == false {
                        CardRow(label: "Goal", value: "\(habitNdx.subhabits.count) steps")
                    } else if habitNdx.hasCheckbox == false {
                        CardRow(label: "Goal", value: "\(habitNdx.goal) \(habitNdx.unit)")
                    }
                    CardRow(label: "Repeats", value: scheduleSummary(useDow: habitNdx.useDow, repeatValue: habitNdx.repeatValue, dow: habitNdx.dow, short: false))
                    CardRow(label: "Time of day", value: habitNdx.timeRegion)
                    CardRow(label: "Reward", value: "\(habitNdx.reward) pts")
                }

                if habitNdx.descript != "" {
                    TextCard(text: habitNdx.descript)
                }

                if habitNdx.subhabits.isEmpty == false {
                    RowCard {
                        ForEach(habitNdx.subhabits.indices, id: \.self) { ndx in
                            Text(habitNdx.subhabits[ndx])
                                .font(Theme.body)
                                .foregroundStyle(Theme.text1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                        }
                    }
                }

                VStack(spacing: 12) {
                    Button("Edit habit") {
                        loadForm(from: habitNdx)
                        DisplayHabitEditor = true
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Remove habit") {
                        confirmRemove = true
                    }
                    .buttonStyle(SecondaryButtonStyle(destructive: true))
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {DisplayHabitEditor = false}
        .sheet(isPresented: $DisplayHabitEditor) {
            habitFormSheet(title: "Edit habit", onCancel: { DisplayHabitEditor = false }) {
                //------------------------------------
                updateHabit(habitToEdit: habitNdx)
                //------------------------------------
                DisplayHabitEditor = false
                indexProtocols(modelContext: modelContext)
                listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")
            }
        }
    }

    // -----------------------------------------------
    //                  END VAR DECLARATIONS
    // ----------------------------------------------

    var body: some View {

        NavigationStack(path: $path) {

            VStack(spacing: 0) {

                ScreenHeader(title: "Habits") {
                    IconButton(systemName: "books.vertical", label: "Browse library") {
                        displayProtocolLibrary = true
                    }
                    IconButton(systemName: "plus", label: "New habit") {
                        resetForm()
                        DisplayHabitMaker = true
                    }
                }

                Picker("Display", selection: $displayByProtocol) {
                    Text("All").tag(false)
                    Text("By protocol").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                if its.isEmpty != true {

                    List {
                        if displayByProtocol == true {
                            ForEach(listOfProtocols ?? []) { index in

                                SectionLabel(index.ProtocolName)
                                    .padding(.top, 8)
                                    .listRowBackground(Theme.bg)
                                    .listRowSeparator(.hidden)
                                    .accessibilityAddTraits(.isHeader)

                                ForEach(its) { habitNdx in

                                    if habitNdx.whichProtocol == index.ProtocolName {
                                        habitRow(habitNdx)
                                    } else {}
                                }.onMove(perform: move)
                            }

                        } else {

                            ForEach(its) { habitNdx in
                                habitRow(habitNdx)
                            }.onMove(perform: move)
                        } // END ELSE (DISPLAY BY PROTOCOL)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                } else {
                    EmptyState(symbol: "repeat",
                               title: "No habits yet",
                               sentence: "Create one, or adopt a set from the library.",
                               buttonTitle: "Browse library") {
                        displayProtocolLibrary = true
                    }
                }
            }
            .background(Theme.bg)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: habItem.self) { habitNdx in
                habitDetail(habitNdx)
            }
        }
        // Presented from the stack rather than the detail page: the page is popped by the
        // Remove action, and a dialog whose presenter disappears mid-dismissal eats the next tap.
        .confirmationDialog("Remove this habit?", isPresented: $confirmRemove, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                if let habitNdx = path.last {
                    path.removeAll()
                    modelContext.delete(habitNdx); try? modelContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $DisplayHabitMaker) {
            habitFormSheet(title: "New habit", onCancel: { DisplayHabitMaker = false }) {
                addItem()
                // addItem re-indexes the protocols; re-read them so By protocol shows the new habit
                listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")
            }
        }
        .sheet(isPresented: $displayProtocolLibrary) {
            ProtocolLibraryModal(isPresented: $displayProtocolLibrary, onIncorporate: {
                listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")
            })
        }
        .onAppear{
            indexProtocols(modelContext: modelContext)
            listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol")
        }
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
        habitToEdit.colorName = HabitColorSet

        habitToEdit.useDow = HabitUseDOWSet

        habitToEdit.dow.onSun = HabitOnSunSet
        habitToEdit.dow.onMon = HabitOnMonSet
        habitToEdit.dow.onTues = HabitOnTuesSet
        habitToEdit.dow.onWed = HabitOnWedSet
        habitToEdit.dow.onThurs = HabitOnThursSet
        habitToEdit.dow.onFri = HabitOnFriSet
        habitToEdit.dow.onSat = HabitOnSatSet

        habitToEdit.hasSubtask = HabitHasSubTaskSet

        if HabitHasSubTaskSet == true {
            habitToEdit.subhabits = HabitSubhabitsSet
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0 != "" }
            if habitToEdit.subhabits.isEmpty {
                habitToEdit.hasSubtask = false
                habitToEdit.hasCheckbox = true
            } else {
                habitToEdit.hasCheckbox = false
                habitToEdit.goal = habitToEdit.subhabits.count
                habitToEdit.unit = "subhabits"
            }
        } else {
            habitToEdit.subhabits = []
        }

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

        if HabitHasSubTaskSet == true {
            HabitSubhabitsSet = HabitSubhabitsSet
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0 != "" }
            if HabitSubhabitsSet.isEmpty {
                // No usable subhabits: fall back to a plain checkbox habit
                HabitHasSubTaskSet = false
                HabitHasCheckboxSet = true
                HabitGoalSet = 1
                HabitUnitSet = "units"
            } else {
                HabitGoalSet = Int16(HabitSubhabitsSet.count)
                HabitUnitSet = "subhabits"
            }
        } else {
            HabitSubhabitsSet = []
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

        newHabitItem.colorName = HabitColorSet
        newHabitItem.subhabits = HabitSubhabitsSet

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
        HabitHasSubTaskSet = false
        HabitSubhabitsSet = []
        HabitTimeRegionSet = "None"
        HabitColorSet = "Default"
        
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
