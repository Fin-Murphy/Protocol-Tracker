//
//  MainListTab.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/16/25.
//

import SwiftUI
import SwiftData

struct navLinkLabel: View {

    var item: listItem

    var body: some View {
        
        HStack{
            
            if item.complete == true {
                                
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 8,height: 8)
                
            } else {
                
                Text("•")
                
            }
            
            if item.isTask == true {
                                
                Image(systemName: "t.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20,height: 20)
                
            } else {
                
//                Text("•")

                Image(systemName: "h.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20,height: 20)
                
            }
            
            if item.complete == true {
                Text(String(item.name))
                    .strikethrough()
                    .foregroundColor(.green)
            } else {
                Text(String(item.name))
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
}

struct valueModView: View {

    var item: listItem
    @Binding var Celebrate: Int
    @Environment(\.modelContext) private var modelContext

    var body: some View {


        if item.complete == true {
            Text("☑ \(item.value)/\(item.goal) \(item.unit)")
                .font(.title)
                .padding()
                .bckMod()

        } else {
            Text("☐ \(item.value)/\(item.goal) \(item.unit)")
                .font(.title)
                .padding()
                .bckMod()
        }

        HStack{
            if item.goal > 10 {
                Button {
                    addValue(item: item, value: 10, modelContext: modelContext, Celebrate: &Celebrate)
                } label: {
                    Text("+ 10")
                        .bckMod()
                }
            }
            if item.goal > 5 {
                Button {
                    addValue(item: item, value: 5, modelContext: modelContext, Celebrate: &Celebrate)
                } label: {
                    Text("+ 5")
                        .bckMod()
                }
            }
            Button {

                addValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
//                    if item.value == item.goal {
//
//                    }
            }
            label: {
                Text("+ 1")
                    .bckMod()
            }

            Button {
                subValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
//                    if item.value == item.goal {
//
//                    }
            } label: {
                Text("- 1")
                    .bckMod()
            }

            if item.goal > 5 {
                Button {
                    subValue(item: item, value: 5, modelContext: modelContext, Celebrate: &Celebrate)
                } label: {
                    Text("- 5")
                        .bckMod()
                }
            }
            if item.goal > 10 {
                Button {
                    subValue(item: item, value: 10, modelContext: modelContext, Celebrate: &Celebrate)
                } label: {
                    Text("- 10")
                        .bckMod()
                }
            }

        } // END HSTACK
    }
}

struct subhabitChecklistView: View {

    var item: listItem
    @Binding var Celebrate: Int
    @Environment(\.modelContext) private var modelContext

    var body: some View {

        if item.complete == true {
            Text("☑ \(item.value)/\(item.goal) \(item.unit)")
                .font(.title)
                .padding()
                .bckMod()

        } else {
            Text("☐ \(item.value)/\(item.goal) \(item.unit)")
                .font(.title)
                .padding()
                .bckMod()
        }

        VStack(alignment: .leading) {
            ForEach(item.subhabits.indices, id: \.self) { ndx in
                Button {
                    var checks = item.subhabitChecked
                    while checks.count < item.subhabits.count { checks.append(false) }
                    if checks[ndx] == true {
                        checks[ndx] = false
                        item.subhabitChecked = checks
                        subValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
                    } else {
                        checks[ndx] = true
                        item.subhabitChecked = checks
                        addValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
                    }
                } label: {
                    HStack {
                        Text(ndx < item.subhabitChecked.count && item.subhabitChecked[ndx] ? "☑" : "☐")
                        Text(item.subhabits[ndx])
                    }
                }
            }
        }
        .bckMod()
    }
}

struct navLinkContent: View {

    @Binding var forceUpdate: Bool

    var item: listItem

    @Environment(\.modelContext) private var modelContext

    @State var updateItemStatus: String = ""

    @Binding var Celebrate: Int

    var body: some View {

        if item.complete == true {
            Text(String(item.name))
                .font(.title)
                .fontWeight(.bold)
                .strikethrough()
        } else {
            Text(String(item.name))
                .font(.title)
                .fontWeight(.bold)
        }

        if item.hasStatus == true {

            VStack {
                HStack {
                    Text("Habit status:")

                    TextField("", text: $updateItemStatus)
                        .frame(maxWidth: 100, alignment: .center)
                        .onChange(of: updateItemStatus) {
                            setStatus(refItem: item, modelContext: modelContext, updateItemStatus: updateItemStatus)
                        }
                }
                .bckMod()

            }
            .onAppear{updateItemStatus = item.statusText}
            .bckMod()


        } else {}

        Spacer()

        ScrollView {

            if item.isTask != true {
                if displayHabitDescription(identifier: item.name, modelContext: modelContext) != "" {
                    Text(displayHabitDescription(identifier: item.name, modelContext: modelContext))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .bckMod()
                }

            } else {
                if item.descriptor != "" {
                    Text(item.descriptor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .bckMod()
                }

            }


        }.frame(width: 350)

        Spacer()

        // ---------------------- BEGIN VALUE MODIFICATION

        if item.subhabits.isEmpty == false {

            subhabitChecklistView(item: item, Celebrate: $Celebrate)

        } else if item.hasCheckbox == false {

            valueModView(item: item, Celebrate: $Celebrate)


        } else {


            if item.complete == true {
                Button{
                    subValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
                    forceUpdate.toggle()
                } label: {
                    Text("☑")
                        .font(.title)
                        .padding()
                        .bckMod()
                }

            } else {
                Button{
                    addValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
                    forceUpdate.toggle()
                } label: {
                    Text("☐")
                        .font(.title)
                        .padding()
                        .bckMod()
                }
            }
        }

        if item.notFloater == true && item.complete == false {

            Button {
                scootItem(item: item, modelContext: modelContext)
            } label: {
                Text("Move this item to tomorrow?")
            }
        }
        // ---------------------- END VALUE MODIFICATION

        Spacer()
    }
}

struct dayListView: View {

    @Binding var forceUpdate: Bool

    @Binding var Celebrate: Int

    @Environment(\.modelContext) private var modelContext

    // Fetches only the selected day's items (plus floaters), rather than every listItem
    @Query private var items: [listItem]

    init(selectedDate: Date, forceUpdate: Binding<Bool>, Celebrate: Binding<Int>) {

        _forceUpdate = forceUpdate
        _Celebrate = Celebrate

        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

        _items = Query(filter: #Predicate<listItem> { item in
            (item.timestamp >= dayStart && item.timestamp < dayEnd) || item.notFloater == false
        }, sort: \listItem.timestamp, animation: .default)
    }

    var body: some View {

        List {

                ForEach(items) { item in
                    if item.complete == false {

                        NavigationLink {

                            navLinkContent(forceUpdate: $forceUpdate, item: item, Celebrate: $Celebrate)


                        } label: {
                            navLinkLabel(item: item)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Complete") {
                                completeHabit(item: item, modelContext: modelContext, Celebrate: &Celebrate)
//                                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
//                                                impactFeedback.impactOccurred()

                                playCustomHaptic()
                            }
                            .tint(.blue)

                        }
                        .swipeActions(edge: .leading) {
                            Button("Delete") {
                                deleteEntity(withUUID: item.id, modelContext: modelContext)
                            }
                            .tint(.red)
                        }
                    } else {}
                }

                ForEach(items) { item in

                    if item.complete == true {

                        NavigationLink {

                            navLinkContent(forceUpdate: $forceUpdate, item: item, Celebrate: $Celebrate)

                        } // End of navigation link
                        label: {

                            navLinkLabel(item: item)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Complete") {
                                completeHabit(item: item, modelContext: modelContext, Celebrate: &Celebrate)
//                                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
//                                                impactFeedback.impactOccurred()
                                playCustomHaptic()
                            }
                            .tint(.blue)

                        }
                        .swipeActions(edge: .leading) {
                            Button("Delete") {
                                deleteEntity(withUUID: item.id, modelContext: modelContext)
                            }
                            .tint(.red)
                        }
                    } else {}
                }

        }//END LIST
    }
}

struct MainListTab: View {
    
    // ---------------------------------------------------------------------------------------------------------------------
    // BINDINGS
    // ---------------------------------------------------------------------------------------------------------------------

    @Binding var selectedTab: Tabs

    @Binding var Celebrate: Int

    @Binding var SelectedDate: Date

    // ---------------------------------------------------------------------------------------------------------------------
    // STATES
    // ---------------------------------------------------------------------------------------------------------------------

    @State var seenWelcome: Bool = !UserDefaults.standard.bool(forKey: "seenWelcome")  // MAKE BINDING

    @State var forceUpdate: Bool = false

    // ---------------------------------------------------------------------------------------------------------------------
    // SWIFTDATA
    // ---------------------------------------------------------------------------------------------------------------------

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \habItem.order, animation: .default)
    private var habitData: [habItem]


    // ---------------------------------------------------------------------------------------------------------------------
    // WELCOME MESSAGE
    // ---------------------------------------------------------------------------------------------------------------------

    private var welcomeMessageView: some View {
    
        VStack{
            Text("Welcome to Protocol Tracker!")
            Text("")
            Text("This app is still under heavy development.")
            Text("If you have any issues or encounter any bugs or errors, please let me know!")
            
            
            Text("")
            Text("The 5 tabs along the bottom of the screen are, in this order, the Calendar tab, the Habit Tab, the Main tab, the Task tab, and the Settings tab.")
            Text("The final version of this app aims to replicate all the functionalities of Org mode in a user-friendly format. If you have suggestions, again please let me know!")
            
            Button{
                UserDefaults.standard.set(true, forKey: "seenWelcome")
                seenWelcome = false
            } label: {
                Text("Get Started")
            }
            
        }.bckMod()
    }//END WELCOMEMESSAGEVIEW
    
    // ---------------------------------------------------------------------------------------------------------------------
    // BODY CONTENT
    // ---------------------------------------------------------------------------------------------------------------------
    
    var body: some View {
         
        VStack{
            
            DateBarView(SelectedDate: $SelectedDate)
            
            ZStack{
                
                NavigationView {
                    
                    VStack{

                        dayListView(selectedDate: SelectedDate, forceUpdate: $forceUpdate, Celebrate: $Celebrate)

                        .onAppear{
                            testTasksForSillyness()
                        }

                    }//END VSTACK
                    
                }//END NAV VIEW
                
                if seenWelcome {
                    welcomeMessageView
                }
                
            }.onAppear{ // END DEPTH STACK
                                
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    
                    if granted {
                                                
                    } else {
                        print("Farg!")
                    }
                }
                
                checkDate()
                Celebrate = scoreFor(date: Date(), modelContext: modelContext)
                
            } // END ZSTACK
            
        }//END VSTACK
        
    } // END VIEWABLE CONTENT
    
    // ---------------------------------------------------------------------------------------------------------------------
    // START PRIVATE FUNCTIONS
    // ---------------------------------------------------------------------------------------------------------------------

    public func checkDate() {
        if let savedDate = UserDefaults.standard.object(forKey: "DailyTaskPopulate?") as? Date {
            
            let comparison = calendar.compare(Date(), to: savedDate, toGranularity: .day)

            if comparison == .orderedDescending {

                // Each day's score already lives in its own dayScore record (written live as
                // habits are completed), so the rollover just needs to refresh the checklist.
                populateTasks()

                generateNotifications(modelContext: modelContext) // NEW ADDITION!! ! ! ! ! ! ! ! ! ! ! ! !
                
                UserDefaults.standard.set(Date(), forKey: "DailyTaskPopulate?")
                Celebrate = 0
                SelectedDate = Date()
            } else {}
            
        } else {
            UserDefaults.standard.set(Date(), forKey: "DailyTaskPopulate?")
            populateTasks()
        }
    }
    
    
    
    // ---------------------------------------------------------------------------------------------------------------------
    // TEST TASKS FOR SILLYNESS
    // ---------------------------------------------------------------------------------------------------------------------

    
    private func testTasksForSillyness() {
        let descriptor = FetchDescriptor<listItem>(predicate: #Predicate { $0.notFloater == false })
        for taskFinder in (try? modelContext.fetch(descriptor)) ?? [] {
            taskFinder.timestamp = Date()
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------
    // POPULATE TASKS
    // ---------------------------------------------------------------------------------------------------------------------


    private func populateTasks() {

        let date = Date()
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "EEEE"
        let dayOfWeek = dformatter.string(from: date)

        // Only tasks and floaters can be acted on below, so fetch just those
        let descriptor = FetchDescriptor<listItem>(predicate: #Predicate { $0.isTask == true || $0.notFloater == false })
        for taskFinder in (try? modelContext.fetch(descriptor)) ?? [] {
            if (taskFinder.isTask == true) && (Calendar.current.isDate(taskFinder.timestamp, equalTo: Date(), toGranularity: .day) != true) && (taskFinder.complete == false) && (taskFinder.notFloater == true){
                    deshuntTask(item: taskFinder)
            } else if taskFinder.notFloater == false {
                taskFinder.timestamp = Date()
            }
        }

        shuntTodaysTasks(modelContext: modelContext)
        
        for index in habitData {
            print("\(index.name) - \(daysBetween(start: index.startDate,end: Calendar.current.startOfDay(for: Date())))")
        }

        for index in habitData {

            if index.useDow == false {

                if (daysBetween(start: Calendar.current.startOfDay(for: index.startDate),
                                end: Calendar.current.startOfDay(for: Date())) >= 0)
                    && (daysBetween(start:  Calendar.current.startOfDay(for: index.startDate),
                                 end: Calendar.current.startOfDay(for: Date())) % index.repeatValue == 0) {

                    modelContext.insert(listItem(from: index, timestamp: Date()))

                }

            } else {

                if  (index.dow.onMon == true && dayOfWeek == "Monday") ||
                    (index.dow.onTues == true && dayOfWeek == "Tuesday") ||
                    (index.dow.onWed == true && dayOfWeek == "Wednesday") ||
                    (index.dow.onThurs == true && dayOfWeek == "Thursday") ||
                    (index.dow.onFri == true && dayOfWeek == "Friday") ||
                    (index.dow.onSat == true && dayOfWeek == "Saturday") ||
                    (index.dow.onSun == true && dayOfWeek == "Sunday")
                {

                    modelContext.insert(listItem(from: index, timestamp: Date()))

                }
            }
        }

        saveContext(modelContext: modelContext)
    }
    
    // ---------------------------------------------------------------------------------------------------------------------
    // DESHUNT TASKS
    // ---------------------------------------------------------------------------------------------------------------------


    private func deshuntTask(item: listItem) {

        let returnedTaskItem = taskItem(descript: item.descriptor,
                                        dueDate: (calendar.date(byAdding: .day, value: 1, to: Date())!),
                                        goal: item.goal,
                                        hasCheckbox: item.hasCheckbox,
                                        id: UUID(),
                                        name: item.name,
                                        notFloater: item.notFloater,
                                        reward: item.reward,
                                        unit: item.unit)

        modelContext.insert(returnedTaskItem)
        modelContext.delete(item)

        saveContext(modelContext: modelContext)
    }
}

//#Preview {
//    MainListTab(selectedTab: .HUB, Celebrate: 0, SelectedDate: Date())
//}
