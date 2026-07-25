//
//  SettingsView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 8/18/25.
//

import SwiftUI

struct SettingsView: View {

    @Binding var selectedTab: Tabs

    @Environment(\.modelContext) private var modelContext

    @State var DailyGoalSet: Int = UserDefaults.standard.integer(forKey: "dailyGoal")
    @State var NotifFreq: Int = UserDefaults.standard.integer(forKey: "notifFreq")
    // integer(forKey:) returns 0 when the key is unset; the mini default is 20 min
    @State var MiniNotifFreq: Int = UserDefaults.standard.integer(forKey: "miniNotifFreq") == 0 ? 20 : UserDefaults.standard.integer(forKey: "miniNotifFreq")

    // Stored as "disabled" so the unset default (false) means enabled, like the hideTab* keys
    @AppStorage("hourlyNotifsDisabled") var hourlyNotifsDisabled: Bool = false
    @AppStorage("miniNotifsDisabled") var miniNotifsDisabled: Bool = false

    @AppStorage("hideTabSettings") var hideTabSettings: Bool = false
    @AppStorage("hideTabHabits") var hideTabHabits: Bool = false
    @AppStorage("hideTabHub") var hideTabHub: Bool = false
    @AppStorage("hideTabLog") var hideTabLog: Bool = false
    @AppStorage("hideTabGraphs") var hideTabGraphs: Bool = false
    @AppStorage("hideTabProtocolList") var hideTabProtocolList: Bool = true
    @AppStorage("hideTabTest") var hideTabTest: Bool = true

    let maxActiveTabs = 6

    var activeTabCount: Int {
        [hideTabSettings, hideTabHabits, hideTabHub, hideTabLog,
         hideTabGraphs, hideTabProtocolList, hideTabTest]
            .filter { !$0 }.count
    }

    var body: some View {
        
        VStack{

            HStack{
                Text("Settings")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding(.bottom)
            }.foregroundColor(ForeColor)
            
            Spacer()
            
            VStack{
                Text("Set daily goal")
                TextField("", value: $DailyGoalSet, format: .number)
                Button {
                    UserDefaults.standard.set(DailyGoalSet, forKey: "dailyGoal")
                } label : {
                    Text("Save daily goal")
                        .bckMod()
                }
                
            }.bckMod()
            
            VStack{
                Toggle("Hourly reminders", isOn: Binding(
                    get: { !hourlyNotifsDisabled },
                    set: { hourlyNotifsDisabled = !$0
                           generateNotifications(modelContext: modelContext) }))
                Text("Notfication Frequency (hours)")
                TextField("Once every ___ hours", value: $NotifFreq, format: .number)
                Button {
                    if NotifFreq > 24 {
                        NotifFreq = 24
                    } else if NotifFreq < 1 {
                        NotifFreq = 1
                    }
                    UserDefaults.standard.set(NotifFreq, forKey: "notifFreq")
                    generateNotifications(modelContext: modelContext)
                } label : {
                    Text("Save Notificiation Frequency")
                        .bckMod()
                }

            }.bckMod()

            VStack{
                Toggle("Mini reminders", isOn: Binding(
                    get: { !miniNotifsDisabled },
                    set: { miniNotifsDisabled = !$0
                           generateNotifications(modelContext: modelContext) }))
                Text("Mini Reminder Frequency (minutes)")
                TextField("Once every ___ minutes", value: $MiniNotifFreq, format: .number)
                Button {
                    if MiniNotifFreq > 120 {
                        MiniNotifFreq = 120
                    } else if MiniNotifFreq < 10 {
                        MiniNotifFreq = 10
                    }
                    UserDefaults.standard.set(MiniNotifFreq, forKey: "miniNotifFreq")
                    generateNotifications(modelContext: modelContext)
                } label : {
                    Text("Save Mini Reminder Frequency")
                        .bckMod()
                }

            }.bckMod()

            VStack{
                Text("Tabs")
//                TabToggleRow(name: "Settings", tab: .Calendar, hidden: $hideTabSettings, canHide: false, canEnable: true, selectedTab: $selectedTab)
//                TabToggleRow(name: "Habits", tab: .Protocols, hidden: $hideTabHabits, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
//                TabToggleRow(name: "Hub", tab: .HUB, hidden: $hideTabHub, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                TabToggleRow(name: "Tasks", tab: .Goals, hidden: $hideTabLog, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                TabToggleRow(name: "Graphs", tab: .Settings, hidden: $hideTabGraphs, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                TabToggleRow(name: "Protocols", tab: .ProtocolList, hidden: $hideTabProtocolList, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
            }.bckMod()

            Spacer()
        }


    }
}

// One row in the Tabs section: tapping the name always navigates there,
// even when the checkbox has removed the tab from the tab bar.
struct TabToggleRow: View {

    let name: String
    let tab: Tabs
    @Binding var hidden: Bool
    // The Settings tab can't be hidden — this pane is the only place
    // to turn tabs back on.
    var canHide: Bool = true
    // False once maxActiveTabs are already showing; blocks checking, not unchecking.
    let canEnable: Bool
    @Binding var selectedTab: Tabs

    var body: some View {
        HStack{
            Button {
                selectedTab = tab
            } label: {
                Text(name)
            }
            Spacer()
            Button {
                hidden.toggle()
            } label: {
                Image(systemName: hidden ? "square" : "checkmark.square")
            }
            .disabled(hidden ? !canEnable : !canHide)
        }
        .foregroundColor(ForeColor)
    }
}

#Preview {
    SettingsView(selectedTab: .constant(.Calendar))
}
