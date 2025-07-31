//
//  ProtocolListView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/22/25.
//

import SwiftUI
import CoreData

struct ProtocolListView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.name, ascending: true)],
        animation: .default)
    private var habitData: FetchedResults<HabitItem>
    
    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    
    @State var listOfProtocols: [HabitProtocol] = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
    @State var displayProtocolLibrary: Bool = false
    
    var body: some View {
        HStack {
            Text("Protocols")
                .fontWeight(.bold)
                .font(.title)
                .padding(.bottom)
            
            Button {
                displayProtocolLibrary = true
            } label: {
                Text("+")
                    .font(.title)
                    .padding(.bottom)
            }
        }.foregroundColor(ForeColor)
        
        ZStack {

            NavigationView {
                List {

                    ForEach(listOfProtocols) { prot in

                        NavigationLink{

                            VStack{

                                Text(prot.ProtocolName)

                                List{
                                    ForEach(habitData){ hab in
                                        
                                        if hab.whichProtocol == prot.ProtocolName {
                                            Text(hab.name ?? "")
                                        } else {}
                                        
                                    }
                                }
                            }

                        } label: {
                            Text(prot.ProtocolName)
                        } // End navlinklabel

                    } // End foreach

                } // End list

            }// End navview
            
            if displayProtocolLibrary {
                VStack{
                    Button{
                        displayProtocolLibrary = false
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
                
            } else {}

        }// End Zstack
        
        
    } // end body
    
    private func incorporateProtocol(refProt: HabitProtocol){
        
        //REWORK TO COREDATA
        
        do {
            let request: NSFetchRequest<HabitItem> = HabitItem.fetchRequest()
            let habitData = try viewContext.fetch(request)
            
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
        
        listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
        
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
        
        listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
        
    }
}

#Preview {
    ProtocolListView()
}
