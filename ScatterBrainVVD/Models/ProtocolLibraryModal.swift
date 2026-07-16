//
//  ProtocolLibraryModal.swift
//  ScatterBrainVVD
//

import SwiftUI
import SwiftData

// The popup browser for the built-in protocol library (AppDefinedProtocolLibrary),
// extracted from ProtocolListView so it can be presented from other pages too.
struct ProtocolLibraryModal: View {

    @Binding var isPresented: Bool

    // Called after a protocol/habit is incorporated so the parent can refresh its protocol list
    var onIncorporate: () -> Void = {}

    @Environment(\.modelContext) private var modelContext

    var body: some View {

        VStack{
            Button{
                isPresented = false
            } label: {
                closeButton
            }
            .padding()

            NavigationView{
                List{


                    ForEach(AppDefinedProtocolLibrary){adp in

                        NavigationLink{

                            Button {
                                incorporateProtocol(refProt: adp)
                            } label: {
                                Text("Add this protocol")
                                    .bckMod()
                            }

                            List{
                                ForEach(adp.ProtocolContent){cont in
                                    NavigationLink {
                                        Text(cont.HabitName)
                                        Button{incorporateHabit(refHab: cont)} label:
                                        {Text("Add this habit")}
                                    } label: {  Text(cont.HabitName) }

                                }
                            }


                        } label: {
                            Text(adp.ProtocolName)
                        }


                    }
                }//end list
            }// end navview

        }
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
