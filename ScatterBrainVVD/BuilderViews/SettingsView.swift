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
    @State var NotifFreq: String = String(UserDefaults.standard.integer(forKey: "notifFreq"))
    // integer(forKey:) returns 0 when the key is unset; the mini default is 20 min
    @State var MiniNotifFreq: String = String(UserDefaults.standard.integer(forKey: "miniNotifFreq") == 0 ? 20 : UserDefaults.standard.integer(forKey: "miniNotifFreq"))

    // Stored as "disabled" so the unset default (false) means enabled, like the hideTab* keys
    @AppStorage("hourlyNotifsDisabled") var hourlyNotifsDisabled: Bool = false
    @AppStorage("miniNotifsDisabled") var miniNotifsDisabled: Bool = false

    // Stored as Date under UserDefaults; only the hour/minute matter.
    // Defaults: 7:00 AM wakeup, 11:00 PM bedtime.
    @State var wakeupTime: Date = UserDefaults.standard.object(forKey: "wakeupTime") as? Date
        ?? Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
    @State var bedtime: Date = UserDefaults.standard.object(forKey: "bedtime") as? Date
        ?? Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!

    @AppStorage("hideTabSettings") var hideTabSettings: Bool = false
    @AppStorage("hideTabHabits") var hideTabHabits: Bool = false
    @AppStorage("hideTabHub") var hideTabHub: Bool = false
    @AppStorage("hideTabLog") var hideTabLog: Bool = false
    @AppStorage("hideTabGraphs") var hideTabGraphs: Bool = false
    @AppStorage("hideTabProtocolList") var hideTabProtocolList: Bool = true
    @AppStorage("hideTabTest") var hideTabTest: Bool = true
    @AppStorage("hideTabEvents") var hideTabEvents: Bool = true

    // The number pad has no return key, so a keyboard toolbar "Done" button
    // clears this to dismiss it.
    private enum NumField { case hourly, mini }
    @FocusState private var focusedField: NumField?

    let maxActiveTabs = 6

    var activeTabCount: Int {
        [hideTabSettings, hideTabHabits, hideTabHub, hideTabLog,
         hideTabGraphs, hideTabProtocolList, hideTabTest, hideTabEvents]
            .filter { !$0 }.count
    }

    var body: some View {

        NavigationStack {
        VStack(spacing: 0) {

            ScreenHeader(title: "Settings")

            Form {
                Section {
                    Toggle("Hourly reminders", isOn: Binding(
                        get: { !hourlyNotifsDisabled },
                        set: { hourlyNotifsDisabled = !$0
                            generateNotifications(modelContext: modelContext) }))
                    HStack {
                        Text("Every")
                        Spacer()
                        TextField("1", text: $NotifFreq)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .hourly)
                            .multilineTextAlignment(.trailing)
                            .font(Theme.value)
                            .frame(maxWidth: 80)
                            .accessibilityLabel("Hours between hourly reminders")
                        Text("hours")
                            .foregroundStyle(Theme.text2)
                    }
                    .onChange(of: NotifFreq) {
                        if let freq = Int(NotifFreq) {
                            UserDefaults.standard.set(min(max(freq, 1), 24), forKey: "notifFreq")
                            generateNotifications(modelContext: modelContext)
                        }
                    }
                } header: {
                    SectionLabel("Hourly digest")
                } footer: {
                    Text("1 to 24")
                }
                .listRowBackground(Theme.surface)

                Section {
                    Toggle("Mini reminders", isOn: Binding(
                        get: { !miniNotifsDisabled },
                        set: { miniNotifsDisabled = !$0
                               generateNotifications(modelContext: modelContext) }))
                    HStack {
                        Text("Every")
                        Spacer()
                        TextField("20", text: $MiniNotifFreq)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .mini)
                            .multilineTextAlignment(.trailing)
                            .font(Theme.value)
                            .frame(maxWidth: 80)
                            .accessibilityLabel("Minutes between mini reminders")
                        Text("minutes")
                            .foregroundStyle(Theme.text2)
                    }
                    .onChange(of: MiniNotifFreq) {
                        if let freq = Int(MiniNotifFreq) {
                            UserDefaults.standard.set(min(max(freq, 10), 120), forKey: "miniNotifFreq")
                            generateNotifications(modelContext: modelContext)
                        }
                    }
                } header: {
                    SectionLabel("Mini reminders")
                } footer: {
                    Text("10 to 120")
                } // Notif Section end
                .listRowBackground(Theme.surface)

                Section {
                    DatePicker("Wake up", selection: $wakeupTime, displayedComponents: .hourAndMinute)
                        .onChange(of: wakeupTime) {
                            UserDefaults.standard.set(wakeupTime, forKey: "wakeupTime")
                            generateNotifications(modelContext: modelContext)
                        }
                    DatePicker("Bedtime", selection: $bedtime, displayedComponents: .hourAndMinute)
                        .onChange(of: bedtime) {
                            UserDefaults.standard.set(bedtime, forKey: "bedtime")
                        }
                } header: {
                    SectionLabel("Sleep")
                }
                .listRowBackground(Theme.surface)

                Section {
//                TabToggleRow(name: "Settings", tab: .Calendar, hidden: $hideTabSettings, canHide: false, canEnable: true, selectedTab: $selectedTab)
//                TabToggleRow(name: "Habits", tab: .Protocols, hidden: $hideTabHabits, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
//                TabToggleRow(name: "Hub", tab: .HUB, hidden: $hideTabHub, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                    TabToggleRow(name: "Tasks", tab: .Goals, hidden: $hideTabLog, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                    TabToggleRow(name: "Graphs", tab: .Settings, hidden: $hideTabGraphs, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                    TabToggleRow(name: "Protocols", tab: .ProtocolList, hidden: $hideTabProtocolList, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                    TabToggleRow(name: "Events", tab: .Events, hidden: $hideTabEvents, canEnable: activeTabCount < maxActiveTabs, selectedTab: $selectedTab)
                } header: {
                    SectionLabel("Tabs")
                } footer: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(activeTabCount) of \(maxActiveTabs) tabs shown")
                        if activeTabCount >= maxActiveTabs {
                            Text("Turn one off to add another.")
                                .foregroundStyle(Theme.warning)
                        }
                    }
                }
                .listRowBackground(Theme.surface)
            }
            .daybookForm()
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
        }
        .background(Theme.bg)
        .toolbar(.hidden, for: .navigationBar)
        }

    }
}

// One row in the Tabs section: tapping the name always navigates there,
// even when the toggle has removed the tab from the tab bar.
struct TabToggleRow: View {

    let name: String
    let tab: Tabs
    @Binding var hidden: Bool
    // The Settings tab can't be hidden — this pane is the only place
    // to turn tabs back on.
    var canHide: Bool = true
    // False once maxActiveTabs are already showing; blocks turning on, not turning off.
    let canEnable: Bool
    @Binding var selectedTab: Tabs

    var body: some View {
        HStack(spacing: 12) {
            Button {
                selectedTab = tab
            } label: {
                HStack {
                    Text(name)
                        .foregroundStyle(Theme.text1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.text3)
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Open \(name)")

            Toggle("Show \(name) tab", isOn: Binding(
                get: { !hidden },
                set: { hidden = !$0 }))
            .labelsHidden()
            .disabled(hidden ? !canEnable : !canHide)
        }
    }
}

#Preview {
    SettingsView(selectedTab: .constant(.Calendar))
}
