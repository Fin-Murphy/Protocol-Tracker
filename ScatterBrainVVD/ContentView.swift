//Hello, my name is Ollama!
//
//  ContentView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/20/25.
//  

import SwiftUI
import SwiftData

struct ContentView: View {
//just to get that green square
    @Environment(\.scenePhase) private var scenePhase

    @State var selectedTab: Tabs = .HUB

    @State var SelectedDate: Date = Date()

    // Seeded from today's stored dayScore in MainListTab.onAppear; the celebration
    // check still rides on this binding.
    @State var Celebrate: Int = 0

    @State var seenWelcome: Bool = !UserDefaults.standard.bool(forKey: "seenWelcome")

    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
    
       VStack{
    
/* *******************************************************
                Calendar TAB
 ****************************************************** */
    
           if selectedTab == .Calendar {
               
//               CalendarView(SelectedDate: $SelectedDate, selectedTab: $selectedTab)
                
               
               SettingsView(selectedTab: $selectedTab)
/* *******************************************************
                       BOOK TAB
****************************************************** */
                
            } else if selectedTab == .Settings {

                GraphTabView()

/* *******************************************************
             MONEY TAB
******************************************************** */
         }
            else if selectedTab == .Protocols {
                                    
                HabitBuilderView()

/* *******************************************************
            GOALS TAB
****************************************************** */
            } else if selectedTab == .Goals {
                
                TaskBuilderView()

/* *******************************************************
            MAIN TASK TAB
****************************************************** */

            } else if selectedTab == .HUB {

                MainListTab(
                    selectedTab: $selectedTab,
                    Celebrate: $Celebrate,
                    SelectedDate: $SelectedDate
                )

            }// END HUB TAB

/* *******************************************************
            PROTOCOL LIST TAB
****************************************************** */

            else if selectedTab == .ProtocolList {

                ProtocolListView()

/* *******************************************************
            TEST TAB
****************************************************** */

            } else if selectedTab == .Test {

                TestView()

/* *******************************************************
            EVENTS TAB
****************************************************** */

            } else if selectedTab == .Events {

                EventBuilderView()

            }
            
            Spacer()

           TabBar(selectedTab: $selectedTab)
       }

       .onAppear{
           generateNotifications(modelContext: modelContext)
           refreshVisualData(ForeColor: &ForeColor)
       }
       .onChange(of: scenePhase) {
               refreshVisualData(ForeColor: &ForeColor)
               if scenePhase == .active { // Refresh the pre-scheduled reminders on foreground
                   generateNotifications(modelContext: modelContext)
               }
       }
    }
}

#Preview {
    ContentView().modelContainer(for: [habItem.self, listItem.self, taskItem.self, dayScore.self, eventItem.self], inMemory: true)
}
