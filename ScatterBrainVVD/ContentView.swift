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
                                    
                HabitBuilderView(viewContext: _viewContext)
                    
/* *******************************************************
            GOALS TAB
****************************************************** */
            } else if selectedTab == .Goals {
                
                TaskBuilderView(viewContext: _viewContext)
                
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
       .onChange(of: scenePhase) {
               refreshVisualData(ForeColor: &ForeColor)
       }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
