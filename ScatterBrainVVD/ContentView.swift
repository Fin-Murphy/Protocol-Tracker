//Hello, my name is Ollama!
//
//  ContentView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/20/25.
//  

import SwiftUI
import CoreData

struct ContentView: View {
//just to get that green square
    @Environment(\.scenePhase) private var scenePhase
    
    @State var selectedTab: Tabs = .HUB
    
    @State var SelectedDate: Date = Date()
        
    // Seeded from today's stored DayData score in MainListTab.onAppear; the celebration
    // check still rides on this binding.
    @State var Celebrate: Int16 = 0
            
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

                GraphTabView()
                    .environment(\.managedObjectContext, viewContext)
             
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

       .onAppear{
           generateNotifications(viewContext: viewContext)
           refreshVisualData(ForeColor: &ForeColor)
       }
       .onChange(of: scenePhase) {
               refreshVisualData(ForeColor: &ForeColor)
       }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
