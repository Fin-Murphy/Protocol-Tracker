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

    private var eventBuilderForm: some View {

        Form {
            Section(header: Text("Event Name:")) {
                TextField("", text: $EventNameSet)
            }
            Section("Event Start Date") {
                DatePicker("Select Date",
                           selection: $EventStartDateSet,
                           displayedComponents: .date)
                .datePickerStyle(.compact)
            }

            Toggle("Choose days of the week to repeat on?", isOn: $EventUseDOWSet)
            if EventUseDOWSet == true {
                Toggle("Repeat on Sunday", isOn: $EventOnSunSet)
                Toggle("Repeat on Monday", isOn: $EventOnMonSet)
                Toggle("Repeat on Tuesday", isOn: $EventOnTuesSet)
                Toggle("Repeat on Wednesday", isOn: $EventOnWedSet)
                Toggle("Repeat on Thursday", isOn: $EventOnThursSet)
                Toggle("Repeat on Friday", isOn: $EventOnFriSet)
                Toggle("Repeat on Saturday", isOn: $EventOnSatSet)
            } else {
                Section(header: Text("Event Interval (1 = Daily, 7 = Weekly, etc):")) {
                    TextField("", value: $EventRepetitionSet, format: .number)
                }
            }

            Toggle("Notify at an exact time?", isOn: $EventUseExactTimeSet)
            if EventUseExactTimeSet == true {
                Section("Event Time") {
                    DatePicker("Select Time",
                               selection: $EventFireTimeSet,
                               displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                }
            } else {
                Section(header: Text("Time of day (event joins that region's reminder digests):")) {
                    Picker("Time of day", selection: $EventTimeRegionSet) {
                        ForEach(timeRegionOptions, id: \.self) { region in
                            Text(region)
                        }
                    }
                }
            }

            Section(header: Text("Event Details")) {
                TextEditor(text: $EventDescriptionSet)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            Section {
                Button {addEvent()} label: {Text("Save Event")}
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
                    Text("Events")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding(.bottom)

                    Button {
                        DisplayEventMaker = true
                    } label: {
                        Text("+")
                            .font(.title)
                            .padding(.bottom)
                    }
                }.foregroundColor(ForeColor)

                if eventData.isEmpty == false {

                    NavigationView {

                        List {
                            ForEach(eventData) { eventNdx in

                                NavigationLink{
                                    ZStack{
                                        VStack {

                                            List{
                                                Text(eventNdx.name)
                                                    .font(.title)
                                                    .padding()
                                                Text("Event start date: \(eventNdx.startDate, formatter: itemFormatter)" )

                                                if eventNdx.useDow == true {

                                                    if eventNdx.dow.onSun == true {Text("Event repeats on Sunday")} else {}
                                                    if eventNdx.dow.onMon == true {Text("Event repeats on Monday")} else {}
                                                    if eventNdx.dow.onTues == true {Text("Event repeats on Tuesday")} else {}
                                                    if eventNdx.dow.onWed == true {Text("Event repeats on Wednesday")} else {}
                                                    if eventNdx.dow.onThurs == true {Text("Event repeats on Thursday")} else {}
                                                    if eventNdx.dow.onFri == true {Text("Event repeats on Friday")} else {}
                                                    if eventNdx.dow.onSat == true {Text("Event repeats on Saturday")} else {}

                                                } else {
                                                    Text("Event repeats every \(eventNdx.repeatValue) days." )
                                                }

                                                if eventNdx.useExactTime == true {
                                                    Text("Notifies at \(eventNdx.fireTime, style: .time)")
                                                } else {
                                                    Text("Notifies during region: \(eventNdx.timeRegion)")
                                                }

                                                Text("Event Description: \n\n \(eventNdx.descript)" )

                                            }

                                            Button{DisplayEventEditor = true} label: {
                                                Text("Edit event").bckMod()
                                            }
                                            Button{deleteEntityEvent(withUUID: eventNdx.id, modelContext: modelContext)} label: {
                                                Text("Remove this event").bckMod()
                                            }
                                        }

                                        if DisplayEventEditor == true {

                                            Form {

                                                Section(header: Text("Event Name:")) {
                                                    TextField("", text: $EventNameSet)
                                                }
                                                Section("Event Start Date") {
                                                    DatePicker("Select Date",
                                                               selection: $EventStartDateSet,
                                                               displayedComponents: .date)
                                                    .datePickerStyle(.compact)
                                                }

                                                Toggle("Choose days of the week to repeat on?", isOn: $EventUseDOWSet)
                                                if EventUseDOWSet == true {
                                                    Toggle("Repeat on Sunday", isOn: $EventOnSunSet)
                                                    Toggle("Repeat on Monday", isOn: $EventOnMonSet)
                                                    Toggle("Repeat on Tuesday", isOn: $EventOnTuesSet)
                                                    Toggle("Repeat on Wednesday", isOn: $EventOnWedSet)
                                                    Toggle("Repeat on Thursday", isOn: $EventOnThursSet)
                                                    Toggle("Repeat on Friday", isOn: $EventOnFriSet)
                                                    Toggle("Repeat on Saturday", isOn: $EventOnSatSet)
                                                } else {
                                                    Section(header: Text("Event Interval (1 = Daily, 7 = Weekly, etc):")) {
                                                        TextField("", value: $EventRepetitionSet, format: .number)
                                                    }
                                                }

                                                Toggle("Notify at an exact time?", isOn: $EventUseExactTimeSet)
                                                if EventUseExactTimeSet == true {
                                                    Section("Event Time") {
                                                        DatePicker("Select Time",
                                                                   selection: $EventFireTimeSet,
                                                                   displayedComponents: .hourAndMinute)
                                                        .datePickerStyle(.compact)
                                                    }
                                                } else {
                                                    Section(header: Text("Time of day (event joins that region's reminder digests):")) {
                                                        Picker("Time of day", selection: $EventTimeRegionSet) {
                                                            ForEach(timeRegionOptions, id: \.self) { region in
                                                                Text(region)
                                                            }
                                                        }
                                                    }
                                                }

                                                Section(header: Text("Event Details")) {
                                                    TextEditor(text: $EventDescriptionSet)
                                                        .frame(minHeight: 100)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                        )
                                                }

                                                Section {
                                                    Button {
                                                        updateEvent(eventToEdit: eventNdx)
                                                        DisplayEventEditor = false
                                                    } label: {Text("Save Event")}
                                                }
                                            }
                                            .onAppear{

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

                                            }

                                        } else {}
                                    }// end zstack
                                    .onAppear {DisplayEventEditor = false}
                                } label: {
                                    HStack {
                                        Text(eventNdx.name)

                                        Spacer()

                                        if eventNdx.useExactTime == true {
                                            Text("\(eventNdx.fireTime, style: .time)")
                                        } else {
                                            Text(eventNdx.timeRegion)
                                        }
                                    }
                                }
                            }
                        }
                    }

                } else {Text("No Events").foregroundColor(ForeColor)}

            }

            if DisplayEventMaker == true {

                VStack{
                    Button {
                        DisplayEventMaker = false
                    } label: {
                        closeButton
                    }.padding()

                    eventBuilderForm

                } // VSTACK
                .frame(width:300,height:700)
                .cornerRadius(10)
                .background(Rectangle()
                    .foregroundColor(.black))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .shadow(radius: 20)

            } else {}

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
