//
//  TabBar.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/21/25.
//

import SwiftUI

enum Tabs: Int {
    case Calendar = 0
    case Settings = 1
    case HUB = 2
    case Protocols = 3
    case Goals = 4
    case ProtocolList = 5
    case Test = 6
    case Events = 7
}


struct TabBar: View {

    @Binding var selectedTab: Tabs

    @AppStorage("hideTabSettings") var hideTabSettings: Bool = false
    @AppStorage("hideTabHabits") var hideTabHabits: Bool = false
    @AppStorage("hideTabHub") var hideTabHub: Bool = false
    @AppStorage("hideTabLog") var hideTabLog: Bool = false
    @AppStorage("hideTabGraphs") var hideTabGraphs: Bool = false
    @AppStorage("hideTabProtocolList") var hideTabProtocolList: Bool = true
    @AppStorage("hideTabTest") var hideTabTest: Bool = true
    @AppStorage("hideTabEvents") var hideTabEvents: Bool = true


    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var indicatorSpace

    // Follows selectedTab one step behind so only the indicator animates; tab content switches instantly
    @State private var indicatorTab: Tabs? = nil

    private struct TabEntry: Identifiable {
        let tab: Tabs
        let label: String
        let icon: String
        var id: Int { tab.rawValue }
    }

    // Today, Habits and Settings are always shown (as before); the rest follow their hideTab flags
    private var entries: [TabEntry] {
        var list = [TabEntry(tab: .HUB, label: "Today", icon: "text.book.closed"),
                    TabEntry(tab: .Protocols, label: "Habits", icon: "repeat")]
        if !hideTabLog { list.append(TabEntry(tab: .Goals, label: "Tasks", icon: "checkmark.square")) }
        if !hideTabGraphs { list.append(TabEntry(tab: .Settings, label: "Graphs", icon: "chart.dots.scatter")) }
        if !hideTabProtocolList { list.append(TabEntry(tab: .ProtocolList, label: "Protocols", icon: "list.bullet.rectangle")) }
        if !hideTabEvents { list.append(TabEntry(tab: .Events, label: "Events", icon: "bell")) }
        list.append(TabEntry(tab: .Calendar, label: "Settings", icon: "gearshape"))
        return list
    }

    var body: some View {

        HStack(spacing: 0) {
            ForEach(entries) { entry in
                let selected = selectedTab == entry.tab

                Button {
                    selectedTab = entry.tab
                } label: {
                    VStack(spacing: 0) {
                        ZStack {
                            if (indicatorTab ?? selectedTab) == entry.tab {
                                DoubleRuleMark()
                                    .matchedGeometryEffect(id: "indicator", in: indicatorSpace)
                            }
                        }
                        .frame(height: 7)
                        .padding(.top, 6)

                        Image(systemName: entry.icon)
                            .symbolVariant(selected ? .fill : .none)
                            .font(.system(size: 22))
                            .frame(height: 26)
                            .padding(.top, 2)

                        Text(entry.label)
                            .font(Theme.tabLabel)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.top, 1)

                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(selected ? Theme.text1 : Theme.text2)
                    .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                    .contentShape(Rectangle())
                }
                .buttonStyle(FadeButtonStyle())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(entry.label)
                .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
                .accessibilityShowsLargeContentViewer {
                    Label(entry.label, systemImage: entry.icon)
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .background(Theme.bg)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.separator).frame(height: 1)
        }
        .onChange(of: selectedTab) {
            withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8)) {
                indicatorTab = selectedTab
            }
        }
    }
}

//#Preview {
//    TabBar(selectedTab: .Calendar)
//}
