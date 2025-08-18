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
        
    @State var Celebrate: Int16 = Int16(UserDefaults.standard.integer(forKey: "TodayScore"))
            
    @State var seenWelcome: Bool = !UserDefaults.standard.bool(forKey: "seenWelcome")
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
    
       VStack{
    
/* *******************************************************
                Calendar TAB
 ****************************************************** */
    
           if selectedTab == .Calendar {
               
//               CalendarView(SelectedDate: $SelectedDate, selectedTab: $selectedTab)
                
               
               SettingsView()
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
                                    
                HabitBuilderView()
                    .environment(\.managedObjectContext, viewContext)

/* *******************************************************
            GOALS TAB
****************************************************** */
            } else if selectedTab == .Goals {
                
                TaskBuilderView()
                    .environment(\.managedObjectContext, viewContext)

/* *******************************************************
            MAIN TASK TAB
****************************************************** */

            } else if selectedTab == .HUB {
            
                MainListTab(
                    selectedTab: $selectedTab,
                    Celebrate: $Celebrate,
                    SelectedDate: $SelectedDate
                )
                .environment(\.managedObjectContext, viewContext)
                
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
