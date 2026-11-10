//
//  EventBuilderView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/25/26.
//

import SwiftUI
import SwiftData

struct EventBuilderView: View {

    @Query(sort: \eventItem.name, animation: .default)
    private var eventData: [eventItem]

    @Environment(\.modelContext) private var modelContext

    @State var DisplayEventMaker: Bool = false
    @State var DisplayEventEditor: Bool = false

    @State var EventNameSet: String = ""
    @State var EventDescriptionSet: String = ""
    @State var EventStartDateSet: Date = Date()
    @State var EventRepetitionSet: Int16 = 1
    @State var EventUseExactTimeSet: Bool = false
    @State var EventFireTimeSet: Date = Date()
    @State var EventTimeRegionSet: String = "None"

    @State var EventUseDOWSet: Bool = false
    // -------------------------------------- DOW REP VALS
    @State var EventOnMonSet: Bool = false
    @State var EventOnTuesSet: Bool = false
    @State var EventOnWedSet: Bool = false
    @State var EventOnThursSet: Bool = false
    @State var EventOnFriSet: Bool = false
    @State var EventOnSatSet: Bool = false
    @State var EventOnSunSet: Bool = false
    // --------------------------------------

    // Pushed event detail pages; emptied to pop back to the list after a removal
    @State private var path: [eventItem] = []
    @State private var confirmRemove: Bool = false

    private var eventBuilderForm: some View {

        Form {
            Section {
                TextField("Event name", text: $EventNameSet)
            } header: {
                SectionLabel("Name")
            }
            .listRowBackground(Theme.surface)

            ScheduleSection(startDate: $EventStartDateSet,
                            useDow: $EventUseDOWSet,
                            interval: $EventRepetitionSet,
                            days: [$EventOnSunSet, $EventOnMonSet, $EventOnTuesSet, $EventOnWedSet,
                                   $EventOnThursSet, $EventOnFriSet, $EventOnSatSet])

            Section {
                Picker("Notify", selection: $EventUseExactTimeSet) {
                    Text("Exact time").tag(true)
                    Text("Time of day").tag(false)
                }
                .pickerStyle(.segmented)

                if EventUseExactTimeSet == true {
                    DatePicker("Time",
                               selection: $EventFireTimeSet,
                               displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                } else {
                    Picker("Time of day", selection: $EventTimeRegionSet) {
                        ForEach(timeRegionOptions, id: \.self) { region in
                            Text(region)
                        }
                    }
                }
            } header: {
                SectionLabel("Notify")
            } footer: {
                if EventUseExactTimeSet == false {
                    Text("Joins that part of the day's reminder digest")
                }
            }
            .listRowBackground(Theme.surface)

            Section {
                NotesEditor(text: $EventDescriptionSet)
            } header: {
                SectionLabel("Notes")
            }
            .listRowBackground(Theme.surface)
        }
        .daybookForm()
    }

    // One form for both create and edit; only the title and the Save action differ
    private func eventFormSheet(title: String, onCancel: @escaping () -> Void, onSave: @escaping () -> Void) -> some View {
        NavigationStack {
            eventBuilderForm
                .formSheetToolbar(title: title, onCancel: onCancel, onSave: onSave)
        }
    }

    // The form fields are shared state, so a new event starts from the defaults rather than
    // from whatever was last edited
    private func resetForm() {
        EventNameSet = ""
        EventDescriptionSet = ""
        EventStartDateSet = Date()
        EventRepetitionSet = 1
        EventUseExactTimeSet = false
        EventFireTimeSet = Date()
        EventTimeRegionSet = "None"

        EventUseDOWSet = false
        EventOnMonSet = false
        EventOnTuesSet = false
        EventOnWedSet = false
        EventOnThursSet = false
        EventOnFriSet = false
        EventOnSatSet = false
        EventOnSunSet = false
    }

    private func eventDetail(_ eventNdx: eventItem) -> some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text(eventNdx.name)
                    .font(Theme.detailTitle)
                    .foregroundStyle(Theme.text1)
                    .accessibilityAddTraits(.isHeader)

                RowCard {
                    CardRow(label: "Starts", value: eventNdx.startDate.formatted(date: .abbreviated, time: .omitted))
                    CardRow(label: "Repeats", value: scheduleSummary(useDow: eventNdx.useDow, repeatValue: eventNdx.repeatValue, dow: eventNdx.dow, short: false))
                    CardRow(label: "Notifies", value: eventNdx.useExactTime
                            ? eventNdx.fireTime.formatted(date: .omitted, time: .shortened)
                            : "During \(eventNdx.timeRegion)")
                }

                if eventNdx.descript != "" {
                    TextCard(text: eventNdx.descript)
                }

                VStack(spacing: 12) {
                    Button("Edit event") {
                        EventNameSet = eventNdx.name
                        EventDescriptionSet = eventNdx.descript
                        EventStartDateSet = eventNdx.startDate
                        EventRepetitionSet = Int16(eventNdx.repeatValue)
                        EventUseExactTimeSet = eventNdx.useExactTime
                        EventFireTimeSet = eventNdx.fireTime
                        EventTimeRegionSet = eventNdx.timeRegion

                        EventUseDOWSet = eventNdx.useDow

                        EventOnSunSet = eventNdx.dow.onSun
                        EventOnMonSet = eventNdx.dow.onMon
                        EventOnTuesSet = eventNdx.dow.onTues
                        EventOnWedSet = eventNdx.dow.onWed
                        EventOnThursSet = eventNdx.dow.onThurs
                        EventOnFriSet = eventNdx.dow.onFri
                        EventOnSatSet = eventNdx.dow.onSat

                        DisplayEventEditor = true
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Remove event") {
                        confirmRemove = true
                    }
                    .buttonStyle(SecondaryButtonStyle(destructive: true))
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {DisplayEventEditor = false}
        .sheet(isPresented: $DisplayEventEditor) {
            eventFormSheet(title: "Edit event", onCancel: { DisplayEventEditor = false }) {
                updateEvent(eventToEdit: eventNdx)
                DisplayEventEditor = false
            }
        }
    }

    // -----------------------------------------------
    //                  END VAR DECLARATIONS
    // ----------------------------------------------

    var body: some View {

        NavigationStack(path: $path) {

            VStack(spacing: 0) {

                ScreenHeader(title: "Events") {
                    IconButton(systemName: "plus", label: "New event") {
                        resetForm()
                        DisplayEventMaker = true
                    }
                }

                if eventData.isEmpty == false {

                    List {
                        ForEach(eventData) { eventNdx in

                            NavigationLink(value: eventNdx) {
                                HStack(spacing: 12) {
                                    Image(systemName: "bell")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Theme.text2)
                                        .accessibilityHidden(true)

                                    Text(eventNdx.name)
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.text1)
                                        .lineLimit(3)

                                    Spacer(minLength: 0)

                                    Group {
                                        if eventNdx.useExactTime == true {
                                            Text("\(eventNdx.fireTime, style: .time)")
                                        } else {
                                            Text(eventNdx.timeRegion)
                                        }
                                    }
                                    .font(Theme.value)
                                    .foregroundStyle(Theme.text2)
                                }
                                .frame(minHeight: 44)
                            }
                            .listRowBackground(Theme.surface)
                            .listRowSeparatorTint(Theme.separator)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                } else {
                    EmptyState(symbol: "bell",
                               title: "No events",
                               sentence: "Events send reminders without adding to your checklist.",
                               buttonTitle: "New event") {
                        resetForm()
                        DisplayEventMaker = true
                    }
                }

            }
            .background(Theme.bg)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: eventItem.self) { eventNdx in
                eventDetail(eventNdx)
            }
        }
        // Presented from the stack rather than the detail page: the page is popped by the
        // Remove action, and a dialog whose presenter disappears mid-dismissal eats the next tap.
        .confirmationDialog("Remove this event?", isPresented: $confirmRemove, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                if let eventNdx = path.last {
                    path.removeAll()
                    deleteEntityEvent(withUUID: eventNdx.id, modelContext: modelContext)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $DisplayEventMaker) {
            eventFormSheet(title: "New event", onCancel: { DisplayEventMaker = false }) {
                addEvent()
            }
        }
    }

    // ------------------------------------ Spacer

    private func updateEvent(eventToEdit: eventItem) {

        EventNameSet = EventNameSet.trimmingCharacters(in: .whitespaces)
        if EventNameSet == "" {
            EventNameSet = "Event"
        }
        if EventRepetitionSet < 1 {
            EventRepetitionSet = 1
        }

        eventToEdit.name = EventNameSet
        eventToEdit.descript = EventDescriptionSet
        eventToEdit.startDate = Calendar.current.startOfDay(for: EventStartDateSet)
        eventToEdit.repeatValue = Int(EventRepetitionSet)
        eventToEdit.useExactTime = EventUseExactTimeSet
        eventToEdit.fireTime = EventFireTimeSet
        eventToEdit.timeRegion = EventTimeRegionSet

        eventToEdit.useDow = EventUseDOWSet

        eventToEdit.dow.onSun = EventOnSunSet
        eventToEdit.dow.onMon = EventOnMonSet
        eventToEdit.dow.onTues = EventOnTuesSet
        eventToEdit.dow.onWed = EventOnWedSet
        eventToEdit.dow.onThurs = EventOnThursSet
        eventToEdit.dow.onFri = EventOnFriSet
        eventToEdit.dow.onSat = EventOnSatSet

        saveContext(modelContext: modelContext)

        generateNotifications(modelContext: modelContext)
    }

    private func addEvent() {

        EventNameSet = EventNameSet.trimmingCharacters(in: .whitespaces)
        if EventNameSet == "" {
            EventNameSet = "Event"
        }
        if EventRepetitionSet < 1 {
            EventRepetitionSet = 1
        }

        if EventUseDOWSet == false {
            EventOnMonSet = false
            EventOnTuesSet = false
            EventOnWedSet = false
            EventOnThursSet = false
            EventOnFriSet = false
            EventOnSatSet = false
            EventOnSunSet = false
        }

        let newEventItem = eventItem(descript: EventDescriptionSet,
                                     fireTime: EventFireTimeSet,
                                     id: UUID(),
                                     name: EventNameSet,
                                     repeatValue: Int(EventRepetitionSet),
                                     startDate: Calendar.current.startOfDay(for: EventStartDateSet),
                                     timeRegion: EventTimeRegionSet,
                                     useDow: EventUseDOWSet,
                                     useExactTime: EventUseExactTimeSet)

        newEventItem.dow = dow(onSun: EventOnSunSet,
                               onMon: EventOnMonSet,
                               onTues: EventOnTuesSet,
                               onWed: EventOnWedSet,
                               onThurs: EventOnThursSet,
                               onFri: EventOnFriSet,
                               onSat: EventOnSatSet)

        modelContext.insert(newEventItem)
        saveContext(modelContext: modelContext)

        // Events change today's pending requests immediately, so rebuild right away
        generateNotifications(modelContext: modelContext)

        DisplayEventMaker = false
        EventNameSet = ""
        EventDescriptionSet = ""
        EventStartDateSet = Date()
        EventRepetitionSet = 1
        EventUseExactTimeSet = false
        EventFireTimeSet = Date()
        EventTimeRegionSet = "None"

        EventUseDOWSet = false
        EventOnMonSet = false
        EventOnTuesSet = false
        EventOnWedSet = false
        EventOnThursSet = false
        EventOnFriSet = false
        EventOnSatSet = false
        EventOnSunSet = false

    }

}

#Preview {
    EventBuilderView()
}
