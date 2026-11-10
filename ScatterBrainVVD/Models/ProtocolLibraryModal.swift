//
//  ProtocolLibraryModal.swift
//  ScatterBrainVVD
//

import SwiftUI
import SwiftData

// Primary button that confirms a library add: turns into "Added" on success fill for 1.5s
private struct LibraryAddButton: View {

    let title: String
    let action: () -> Void

    @State private var added = false

    var body: some View {
        Button {
            action()
            added = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                added = false
            }
        } label: {
            if added {
                Label("Added", systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
        .buttonStyle(PrimaryButtonStyle(fill: added ? Theme.success : Theme.accent))
    }
}

// The sheet browser for the built-in protocol library (AppDefinedProtocolLibrary),
// extracted from ProtocolListView so it can be presented from other pages too.
struct ProtocolLibraryModal: View {

    @Binding var isPresented: Bool

    // Called after a protocol/habit is incorporated so the parent can refresh its protocol list
    var onIncorporate: () -> Void = {}

    @Environment(\.modelContext) private var modelContext

    private func habitPage(_ cont: Habit) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text(cont.HabitName)
                    .font(Theme.detailTitle)
                    .foregroundStyle(Theme.text1)
                    .accessibilityAddTraits(.isHeader)

                if cont.HabitHasCheckbox == false {
                    RowCard {
                        CardRow(label: "Goal", value: "\(cont.HabitGoal) \(cont.HabitUnit)")
                    }
                }

                if cont.HabitDescription != "" {
                    TextCard(text: cont.HabitDescription)
                }

                LibraryAddButton(title: "Add this habit") {
                    incorporateHabit(refHab: cont)
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func protocolPage(_ adp: HabitProtocol) -> some View {
        List{
            LibraryAddButton(title: "Add all \(adp.ProtocolContent.count) habits") {
                incorporateProtocol(refProt: adp)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
            .listRowBackground(Theme.bg)
            .listRowSeparator(.hidden)

            ForEach(adp.ProtocolContent){cont in
                NavigationLink {
                    habitPage(cont)
                } label: {
                    Text(cont.HabitName)
                        .font(Theme.body)
                        .foregroundStyle(Theme.text1)
                        .frame(minHeight: 44)
                }
                .listRowBackground(Theme.surface)
                .listRowSeparatorTint(Theme.separator)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .navigationTitle(adp.ProtocolName)
        .navigationBarTitleDisplayMode(.inline)
    }

    var body: some View {

        NavigationStack{
            List{

                ForEach(AppDefinedProtocolLibrary){adp in

                    NavigationLink{

                        protocolPage(adp)

                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(adp.ProtocolName)
                                .font(Theme.body)
                                .foregroundStyle(Theme.text1)
                            Text("\(adp.ProtocolContent.count) habits")
                                .font(Theme.meta)
                                .foregroundStyle(Theme.text2)
                        }
                        .frame(minHeight: 44)
                    }
                    .listRowBackground(Theme.surface)
                    .listRowSeparatorTint(Theme.separator)

                }
            }//end list
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }// end navstack
        .presentationDetents([.large])

    } // end body

    private func incorporateProtocol(refProt: HabitProtocol){

        for habit in refProt.ProtocolContent {
            incorporateHabit(refHab: habit)
        }

    }

    private func incorporateHabit(refHab: Habit){

        let newHabitItem = habItem(descript: refHab.HabitDescription,
                                   goal: Int(refHab.HabitGoal),
                                   hasCheckbox: refHab.HabitHasCheckbox,
                                   hasStatus: refHab.HabitHasStatus,
                                   hasSubtask: refHab.HabitHasSubtask,
                                   id: UUID(),
                                   name: refHab.HabitName,
                                   order: Int(refHab.HabitOrdering),
                                   repeatValue: refHab.HabitRepeatValue,
                                   reward: Int(refHab.HabitReward),
                                   startDate: Calendar.current.startOfDay(for: Date()),
                                   superTask: refHab.HabitSuperTask,
                                   timeRegion: refHab.HabitTimeRegion ?? "None",
                                   unit: refHab.HabitUnit,
                                   useDow: refHab.HabitUseDow,
                                   whichProtocol: refHab.HabitProtocol)

        newHabitItem.colorName = refHab.HabitColor ?? "Default"

        newHabitItem.dow = dow(onSun: refHab.HabitOnSun,
                               onMon: refHab.HabitOnMon,
                               onTues: refHab.HabitOnTues,
                               onWed: refHab.HabitOnWed,
                               onThurs: refHab.HabitOnThurs,
                               onFri: refHab.HabitOnFri,
                               onSat: refHab.HabitOnSat)

        newHabitItem.subhabits = refHab.HabitSubhabits ?? []

        modelContext.insert(newHabitItem)
        try? modelContext.save()

        indexProtocols(modelContext: modelContext)

        onIncorporate()

    }
}
