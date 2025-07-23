//
//  ContentView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/20/25.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @Environment(\.scenePhase) private var scenePhase
        
    @State var selectedTab: Tabs = .HUB
    
    @State var SelectedDate: Date = Date()
    
    @State var moveCompleteHabits: Bool = false
    
    @State var Celebrate: Int16 = 0
        
    @State var habitData: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
    
    @State var seenWelcome: Bool = !UserDefaults.standard.bool(forKey: "seenWelcome")
    
    @Environment(\.managedObjectContext) public var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
        

    var body: some View {
    
       VStack{
    
/* *******************************************************
                Calendar TAB
 ****************************************************** */
    
           if selectedTab == .Calendar {
               
               CalendarView(SelectedDate: $SelectedDate, selectedTab: $selectedTab)
                
/* *******************************************************
                       BOOK TAB
****************************************************** */
                
            } else if selectedTab == .Settings {
                                    
                GoalSetView()
             
/* *******************************************************
             MONEY TAB
******************************************************** */
         }
            else if selectedTab == .Protocols {
                                    
                HabitBuilderView(viewContext: _viewContext, selectedTab: $selectedTab)
                    
/* *******************************************************
            GOALS TAB
****************************************************** */
            } else if selectedTab == .Goals {
                
                TaskBuilderView(context: _viewContext, selectedTab: $selectedTab)
                
/* *******************************************************
            MAIN TASK TAB
****************************************************** */
            
                
            } else if selectedTab == .HUB {
            
                
                MainListTab(
                    selectedTab: $selectedTab,
                    Celebrate: $Celebrate,
                    SelectedDate: $SelectedDate//,
//                    moveCompleteHabits: $moveCompleteHabits
                )
                
            }// END HUB TAB
            
            Spacer()
                        
            TabBar(selectedTab: $selectedTab)
       }
        
    
       .onAppear{refreshVisualData(ForeColor: &ForeColor)}
       .onChange(of: scenePhase) {/*newval in*/
               refreshVisualData(ForeColor: &ForeColor)
       }
    }
    
    
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
