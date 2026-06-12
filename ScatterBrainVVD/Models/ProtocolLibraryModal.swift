//
//  ProtocolLibraryModal.swift
//  ScatterBrainVVD
//

import SwiftUI
import CoreData

// The popup browser for the built-in protocol library (AppDefinedProtocolLibrary),
// extracted from ProtocolListView so it can be presented from other pages too.
struct ProtocolLibraryModal: View {

    @Binding var isPresented: Bool

    // Called after a protocol/habit is incorporated so the parent can refresh its protocol list
    var onIncorporate: () -> Void = {}

    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext

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
        .shadow(radius: 20)

    } // end body

    private func incorporateProtocol(refProt: HabitProtocol){

        //REWORK TO COREDATA

        do {

            for habit in refProt.ProtocolContent {

                let newHabitItem = HabitItem(context: viewContext)

                newHabitItem.id = UUID()

                newHabitItem.name = habit.HabitName
                newHabitItem.goal = habit.HabitGoal
                newHabitItem.unit = habit.HabitUnit
                newHabitItem.whichProtocol = habit.HabitProtocol
                newHabitItem.repeatValue = Int16(habit.HabitRepeatValue)
                newHabitItem.descript = habit.HabitDescription
                newHabitItem.startDate = Calendar.current.startOfDay(for: Date())
                newHabitItem.reward = habit.HabitReward
                newHabitItem.hasStatus = habit.HabitHasStatus
                newHabitItem.hasCheckbox = habit.HabitHasCheckbox

                newHabitItem.order = habit.HabitOrdering

                newHabitItem.useDow = habit.HabitUseDow

                newHabitItem.onSun = habit.HabitOnSun
                newHabitItem.onMon = habit.HabitOnMon
                newHabitItem.onTues = habit.HabitOnTues
                newHabitItem.onWed = habit.HabitOnWed
                newHabitItem.onThurs = habit.HabitOnThurs
                newHabitItem.onFri = habit.HabitOnFri
                newHabitItem.onSat = habit.HabitOnSat

            }

            try viewContext.save()

        } catch {}


        indexProtocols(viewContext: viewContext)

        onIncorporate()

    }

    private func incorporateHabit(refHab: Habit){

        //REWORK TO COREDATA

        let newHabitItem = HabitItem(context: viewContext)

        newHabitItem.id = UUID()

        newHabitItem.name = refHab.HabitName
        newHabitItem.goal = refHab.HabitGoal
        newHabitItem.unit = refHab.HabitUnit
        newHabitItem.whichProtocol = refHab.HabitProtocol
        newHabitItem.repeatValue = Int16(refHab.HabitRepeatValue)
        newHabitItem.descript = refHab.HabitDescription
        newHabitItem.startDate = Calendar.current.startOfDay(for: Date())
        newHabitItem.reward = refHab.HabitReward
        newHabitItem.hasStatus = refHab.HabitHasStatus
        newHabitItem.hasCheckbox = refHab.HabitHasCheckbox

        newHabitItem.order = refHab.HabitOrdering

        newHabitItem.useDow = refHab.HabitUseDow

        newHabitItem.onSun = refHab.HabitOnSun
        newHabitItem.onMon = refHab.HabitOnMon
        newHabitItem.onTues = refHab.HabitOnTues
        newHabitItem.onWed = refHab.HabitOnWed
        newHabitItem.onThurs = refHab.HabitOnThurs
        newHabitItem.onFri = refHab.HabitOnFri
        newHabitItem.onSat = refHab.HabitOnSat

        do {
            try viewContext.save()
        } catch {}

        indexProtocols(viewContext: viewContext)

        onIncorporate()

    }
}
