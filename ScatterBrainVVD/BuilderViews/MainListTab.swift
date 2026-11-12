//
//  MainListTab.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/16/25.
//

import SwiftUI
import SwiftData

// Items moved to tomorrow get renamed with a "> " prefix by scootItem(); strip it for display only
private func displayName(_ name: String) -> String {
    var trimmed = name
    while trimmed.hasPrefix("> ") {
        trimmed = String(trimmed.dropFirst(2))
    }
    return trimmed
}

private func progressFraction(_ item: listItem) -> Double {
    item.goal > 0 ? Double(item.value) / Double(item.goal) : 0
}

// The text column and trailing value of a checklist row (the check control sits beside it)
struct navLinkLabel: View {

    var item: listItem

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var scooted: Bool { item.name.hasPrefix("> ") }

    private var metaLine: String {
        if scooted { return "Moved to tomorrow" }

        var parts: [String] = []
        if item.subhabits.isEmpty == false {
            parts.append("\(item.subhabits.count) steps")
        } else if item.hasCheckbox == false && item.unit != "" {
            parts.append(item.unit)
        }
        parts.append("+\(item.reward) pts")
        if item.timeRegion != "" && item.timeRegion != "None" { parts.append(item.timeRegion) }
        if item.notFloater == false { parts.append("Carries over") }
        if item.hasStatus && item.statusText != "" { parts.append(item.statusText) }
        return parts.joined(separator: " · ")
    }

    private var showsValue: Bool { item.hasCheckbox == false && scooted == false }

    private var valueText: some View {
        Text("\(item.value)/\(item.goal)")
            .font(Theme.value)
            .foregroundStyle(Theme.text2)
    }

    var body: some View {

        HStack(alignment: .center, spacing: 12) {

            VStack(alignment: .leading, spacing: 2) {
                Text(displayName(item.name))
                    .font(Theme.body)
                    .strikethrough(item.complete)
                    .foregroundStyle(scooted ? Theme.text3 : (item.complete ? Theme.text2 : Theme.text1))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                Text(metaLine)
                    .font(Theme.meta)
                    .foregroundStyle(Theme.text2)
                    .multilineTextAlignment(.leading)

                if showsValue && dynamicTypeSize.isAccessibilitySize {
                    valueText
                }
            }

            Spacer(minLength: 0)

            if showsValue && dynamicTypeSize.isAccessibilitySize == false {
                valueText
            }
        }
    }
}

struct valueModView: View {

    var item: listItem
    @Binding var Celebrate: Int
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func chip(_ amount: Int) -> some View {
        Button(amount > 0 ? "+\(amount)" : "−\(-amount)") {
            if amount > 0 {
                addValue(item: item, value: amount, modelContext: modelContext, Celebrate: &Celebrate)
            } else {
                subValue(item: item, value: -amount, modelContext: modelContext, Celebrate: &Celebrate)
            }
        }
        .buttonStyle(ChipButtonStyle())
        .accessibilityLabel(amount > 0 ? "Add \(amount)" : "Subtract \(-amount)")
    }

    var body: some View {

        VStack(spacing: 16) {

            progressReadout(item: item)

            Rectangle()
                .fill(Theme.separator)
                .frame(height: 2)
                .overlay(alignment: .leading) {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(habitColor(item.colorName))
                            .frame(width: geo.size.width * min(max(progressFraction(item), 0), 1))
                            .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: item.value)
                    }
                }
                .accessibilityHidden(true)

            HStack(spacing: 8) {
                if item.goal > 10 { chip(-10) }
                if item.goal > 5 { chip(-5) }
                chip(-1)
                chip(1)
                if item.goal > 5 { chip(5) }
                if item.goal > 10 { chip(10) }
            } // END HSTACK
        }
    }
}

// Centred "value / goal" with the unit beneath, shared by the progress and subhabit blocks
private struct progressReadout: View {

    var item: listItem

    var body: some View {
        VStack(spacing: 4) {
            Text("\(item.value) / \(item.goal)")
                .font(Theme.bigValue)
                .foregroundStyle(item.complete ? Theme.text2 : Theme.text1)
            Text(item.unit)
                .font(Theme.meta)
                .foregroundStyle(Theme.text2)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.value) of \(item.goal) \(item.unit)")
    }
}

struct subhabitChecklistView: View {

    var item: listItem
    @Binding var Celebrate: Int
    @Environment(\.modelContext) private var modelContext

    private func isChecked(_ ndx: Int) -> Bool {
        ndx < item.subhabitChecked.count && item.subhabitChecked[ndx]
    }

    var body: some View {

        VStack(spacing: 16) {

            progressReadout(item: item)

            RowCard {
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
                        HStack(spacing: 12) {
                            CheckControl(isTask: false, complete: isChecked(ndx), colorName: item.colorName, size: 20)
                            Text(item.subhabits[ndx])
                                .font(Theme.body)
                                .strikethrough(isChecked(ndx))
                                .foregroundStyle(isChecked(ndx) ? Theme.text2 : Theme.text1)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(FadeButtonStyle())
                    .accessibilityLabel(item.subhabits[ndx])
                    .accessibilityValue(isChecked(ndx) ? "done" : "not done")
                }
            }
        }
    }
}

// Item detail, pushed from a checklist row
struct navLinkContent: View {

    @Binding var forceUpdate: Bool

    var item: listItem

    @Environment(\.modelContext) private var modelContext

    @State var updateItemStatus: String = ""

    @Binding var Celebrate: Int

    private var metaLine: String {
        var parts: [String] = [item.isTask ? "Task" : "Habit", "+\(item.reward) pts"]
        if item.timeRegion != "" && item.timeRegion != "None" { parts.append(item.timeRegion) }
        if item.notFloater == false { parts.append("Carries over") }
        return parts.joined(separator: " · ")
    }

    private var descriptionText: String {
        item.isTask != true ? displayHabitDescription(identifier: item.name, modelContext: modelContext) : item.descriptor
    }

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 24) {

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName(item.name))
                        .font(Theme.detailTitle)
                        .strikethrough(item.complete)
                        .foregroundStyle(item.complete ? Theme.text2 : Theme.text1)
                        .accessibilityAddTraits(.isHeader)
                    Text(metaLine)
                        .font(Theme.meta)
                        .foregroundStyle(Theme.text2)
                }

                if item.hasStatus == true {

                    VStack(alignment: .leading, spacing: 8) {
                        SectionLabel("Status")

                        TextField("", text: $updateItemStatus)
                            .font(Theme.body)
                            .foregroundStyle(Theme.text1)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Theme.sunken, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .accessibilityLabel("Status")
                            .onChange(of: updateItemStatus) {
                                setStatus(refItem: item, modelContext: modelContext, updateItemStatus: updateItemStatus)
                            }
                    }
                    .onAppear{updateItemStatus = item.statusText}

                }

                if descriptionText != "" {
                    TextCard(text: descriptionText)
                }

                // ---------------------- BEGIN VALUE MODIFICATION

                if item.subhabits.isEmpty == false {

                    subhabitChecklistView(item: item, Celebrate: $Celebrate)

                } else if item.hasCheckbox == false {

                    valueModView(item: item, Celebrate: $Celebrate)

                } else {

                    if item.complete == true {
                        Button("Mark not done") {
                            subValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
                            forceUpdate.toggle()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                    } else {
                        Button("Mark done") {
                            addValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
                            forceUpdate.toggle()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }

                if item.notFloater == true && item.complete == false {

                    Button("Move to tomorrow") {
                        scootItem(item: item, modelContext: modelContext)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                // ---------------------- END VALUE MODIFICATION
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct dayListView: View {

    @Binding var forceUpdate: Bool

    @Binding var Celebrate: Int

    @Binding var selectedTab: Tabs

    @Environment(\.modelContext) private var modelContext

    // Fetches only the selected day's items (plus floaters), rather than every listItem
    @Query private var items: [listItem]

    @State private var openItem: listItem? = nil

    init(selectedDate: Date, forceUpdate: Binding<Bool>, Celebrate: Binding<Int>, selectedTab: Binding<Tabs>) {

        _forceUpdate = forceUpdate
        _Celebrate = Celebrate
        _selectedTab = selectedTab

        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

        _items = Query(filter: #Predicate<listItem> { item in
            (item.timestamp >= dayStart && item.timestamp < dayEnd) || item.notFloater == false
        }, sort: \listItem.timestamp, animation: .spring(response: 0.35, dampingFraction: 0.85))
    }

    private func complete(_ item: listItem) {
        completeHabit(item: item, modelContext: modelContext, Celebrate: &Celebrate)
//                                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
//                                                impactFeedback.impactOccurred()
    }

    // Tap shortcuts on the check control; anything it can't finish in one tap opens the detail
    private func controlTapped(_ item: listItem) {
        if item.subhabits.isEmpty == false || (item.hasCheckbox == false && item.complete == true) {
            openItem = item
        } else if item.hasCheckbox == true {
            if item.complete == true {
                subValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
            } else {
                complete(item)
            }
        } else {
            addValue(item: item, value: 1, modelContext: modelContext, Celebrate: &Celebrate)
        }
    }

    private func controlLabel(_ item: listItem) -> String {
        if item.subhabits.isEmpty == false || (item.hasCheckbox == false && item.complete == true) {
            return "Open \(item.name)"
        } else if item.hasCheckbox == true {
            return item.complete ? "Mark \(item.name) not done" : "Mark \(item.name) done"
        }
        return "Add one"
    }

    private func rowLabel(_ item: listItem) -> String {
        var parts = [displayName(item.name), item.isTask ? "task" : "habit"]
        if item.hasCheckbox == false { parts.append("\(item.value) of \(item.goal) \(item.unit)") }
        if item.name.hasPrefix("> ") {
            parts.append("moved to tomorrow")
        } else {
            parts.append(item.complete ? "done" : "not done")
        }
        return parts.joined(separator: ", ")
    }

    @ViewBuilder
    private func row(_ item: listItem) -> some View {

        let scooted = item.name.hasPrefix("> ")
        let canScoot = item.notFloater == true && item.complete == false

        HStack(spacing: 0) {

            if scooted == false {
                Button {
                    controlTapped(item)
                } label: {
                    CheckControl(isTask: item.isTask,
                                 complete: item.complete,
                                 fraction: item.hasCheckbox ? nil : progressFraction(item),
                                 colorName: item.colorName)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(FadeButtonStyle())
                .accessibilityLabel(controlLabel(item))
            }

            Button {
                openItem = item
            } label: {
                HStack(spacing: 0) {
                    if scooted {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.text3)
                            .frame(width: 44, height: 44)
                    }
                    navLinkLabel(item: item)
                        .padding(.leading, 3)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(FadeButtonStyle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rowLabel(item))
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(named: "Complete") { complete(item) }
            .accessibilityActions {
                if canScoot {
                    Button("Move to tomorrow") { scootItem(item: item, modelContext: modelContext) }
                }
                Button("Delete") { deleteEntity(withUUID: item.id, modelContext: modelContext) }
            }
        }
        .padding(.leading, 7)
        .padding(.trailing, 16)
        .padding(.vertical, 6)
        .frame(minHeight: 56)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Theme.surface)
        .listRowSeparatorTint(Theme.separator)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .alignmentGuide(.listRowSeparatorTrailing) { $0.width }
        .swipeActions(edge: .trailing) {
            Button {
                complete(item)
            } label: {
                Label("Complete", systemImage: "checkmark")
            }
            .tint(Theme.success)

            if canScoot {
                Button {
                    scootItem(item: item, modelContext: modelContext)
                } label: {
                    Label("Tomorrow", systemImage: "arrow.right")
                }
                .tint(Theme.warning)
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                deleteEntity(withUUID: item.id, modelContext: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(Theme.destructive)
        }
    }

    private func groupLabel(_ text: String) -> some View {
        SectionLabel(text)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Theme.bg)
            .listRowSeparator(.hidden)
            .accessibilityAddTraits(.isHeader)
    }

    var body: some View {

        let todo = items.filter { $0.complete == false }
        let done = items.filter { $0.complete == true }

        Group {
            if items.isEmpty {

                EmptyState(symbol: "text.book.closed",
                           title: "Nothing on this page",
                           sentence: "Habits appear here on the days they repeat. Tasks appear on their date.",
                           buttonTitle: "Add a habit") {
                    selectedTab = .Protocols
                }

            } else {

                List {

                    if todo.isEmpty == false {
                        groupLabel("To do")
                        ForEach(todo) { item in
                            row(item)
                        }
                    }

                    if done.isEmpty == false {
                        groupLabel("Done · \(done.count)")
                        ForEach(done) { item in
                            row(item)
                        }
                    }

                }//END LIST
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Theme.bg)
        .navigationDestination(item: $openItem) { item in
            navLinkContent(forceUpdate: $forceUpdate, item: item, Celebrate: $Celebrate)
        }
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

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome to Protocol Tracker")
                    .font(Theme.detailTitle)
                    .foregroundStyle(Theme.text1)
                    .accessibilityAddTraits(.isHeader)

                Text("Build habits and tasks, and each day's checklist fills itself in. Tick things off to earn points; the day closes when every point is earned. Habits, Tasks and Graphs are along the bottom, and more tabs can be turned on in Settings.")
                    .font(Theme.body)
                    .foregroundStyle(Theme.text1)

                Button("Get started") {
                    UserDefaults.standard.set(true, forKey: "seenWelcome")
                    seenWelcome = false
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            .padding(.bottom, 16)
        }
        .presentationDetents([.medium])
        .presentationBackground(Theme.surface)
    }//END WELCOMEMESSAGEVIEW
    
    // ---------------------------------------------------------------------------------------------------------------------
    // BODY CONTENT
    // ---------------------------------------------------------------------------------------------------------------------
    
    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                DateBarView(SelectedDate: $SelectedDate)

                dayListView(selectedDate: SelectedDate, forceUpdate: $forceUpdate, Celebrate: $Celebrate, selectedTab: $selectedTab)

                .onAppear{
                    testTasksForSillyness()
                }

            }//END VSTACK
            .background(Theme.bg)
            .toolbar(.hidden, for: .navigationBar)

        }//END NAV STACK
        .sheet(isPresented: $seenWelcome) {
            welcomeMessageView
        }
        .onAppear{


            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in

                if granted {

                } else {
                    print("Farg!")
                }
            }

            checkDate()
            Celebrate = scoreFor(date: Date(), modelContext: modelContext)

        }

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
