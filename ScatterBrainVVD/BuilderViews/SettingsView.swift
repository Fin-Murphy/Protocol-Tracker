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

    // String-backed so the field can go blank while editing; only valid numbers
    // are saved, so a blank field falls back to the stored value when the view
    // is recreated on tab switch.
    @State var DailyGoalSet: String = String(UserDefaults.standard.integer(forKey: "dailyGoal"))
    @State var NotifFreq: String = String(UserDefaults.standard.integer(forKey: "notifFreq"))
    // integer(forKey:) returns 0 when the key is unset; the mini default is 20 min
    @State var MiniNotifFreq: String = String(UserDefaults.standard.integer(forKey: "miniNotifFreq") == 0 ? 20 : UserDefaults.standard.integer(forKey: "miniNotifFreq"))

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
    @AppStorage("hideTabEvents") var hideTabEvents: Bool = true

    let maxActiveTabs = 6

    var activeTabCount: Int {
        [hideTabSettings, hideTabHabits, hideTabHub, hideTabLog,
         hideTabGraphs, hideTabProtocolList, hideTabTest, hideTabEvents]
            .filter { !$0 }.count
    }

    var body: some View {
        
        VStack{

            HStack{
                Text("Settings")
                    .fontWeight(.bold)
                    .font(.title)
            }.foregroundColor(ForeColor)

            Form {
                Section {
                    LabeledContent("Daily goal") {
                        TextField("0", text: $DailyGoalSet)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 80)
                    }
                    .onChange(of: DailyGoalSet) {
                        if let goal = Int(DailyGoalSet) {
                            UserDefaults.standard.set(goal, forKey: "dailyGoal")
                        }
                    }
                }

                Section("Digest Notifications") {
                    Toggle("Hourly reminders", isOn: Binding(
                        get: { !hourlyNotifsDisabled },
                        set: { hourlyNotifsDisabled = !$0
                            generateNotifications(modelContext: modelContext) }))
                    LabeledContent("Frequency (hours)") {
                        TextField("1", text: $NotifFreq)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 80)
                    }
                    .onChange(of: NotifFreq) {
                        if let freq = Int(NotifFreq) {
                            UserDefaults.standard.set(min(max(freq, 1), 24), forKey: "notifFreq")
                            generateNotifications(modelContext: modelContext)
                        }
                    }
                }
                
                Section("Mini Notifications") {
                    Toggle("Mini reminders", isOn: Binding(
                        get: { !miniNotifsDisabled },
                        set: { miniNotifsDisabled = !$0
                               generateNotifications(modelContext: modelContext) }))
                    LabeledContent("Mini frequency (minutes)") {
                        TextField("20", text: $MiniNotifFreq)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 80)
                    }
                    .onChange(of: MiniNotifFreq) {
                        if let freq = Int(MiniNotifFreq) {
                            UserDefaults.standard.set(min(max(freq, 10), 120), forKey: "miniNotifFreq")
                            generateNotifications(modelContext: modelContext)
                        }
                    }
                } // Notif Section end

                Section("Tabs") {
//                TabToggleRow(name: "Settings", tab: .Calendar, hidden: $hideTabSettings, canHide: false, canEnable: true, selectedTab: $selectedTab)
//                TabToggleRow(name: "Habits", tab: .Protocols, hidden: $hideTabHabits, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
//                TabToggleRow(name: "Hub", tab: .HUB, hidden: $hideTabHub, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                    TabToggleRow(name: "Tasks", tab: .Goals, hidden: $hideTabLog, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                    TabToggleRow(name: "Graphs", tab: .Settings, hidden: $hideTabGraphs, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                    TabToggleRow(name: "Protocols", tab: .ProtocolList, hidden: $hideTabProtocolList, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                    TabToggleRow(name: "Events", tab: .Events, hidden: $hideTabEvents, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                }
            }
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
