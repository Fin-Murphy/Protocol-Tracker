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


    var body: some View {
       
        HStack {
            
            //-----------------------------------------------
            Spacer()
            //-----------------------------------------------
            
            if !hideTabSettings {
            if selectedTab == .Calendar {

                    Button {
                        selectedTab = .Calendar
                    }
                    label: {
                        SymbolButton(bIcon: "gearshape.fill", bTxt: "Settings")
                    }.foregroundColor(ForeColor)

            } else { // shit commit

                    Button {
                        selectedTab = .Calendar
                    }
                    label: {
                        SymbolButton(bIcon: "gearshape", bTxt: "")
                    }.foregroundColor(ForeColor)

            }
            }
            
            //-----------------------------------------------
            //Spacer()
            //-----------------------------------------------
            
        
            //-----------------------------------------------
            
            if !hideTabHabits {
            if selectedTab == .Protocols {

                    Button {
                        selectedTab = .Protocols
                    } label: {
                        SymbolButton(bIcon: "arrowtriangle.down.square.fill", bTxt: "Habits")
                    }.foregroundColor(ForeColor)

            } else {

                    Button {
                        selectedTab = .Protocols
                    } label: {
                        SymbolButton(bIcon: "arrowtriangle.down.square", bTxt: "")
                    }.foregroundColor(ForeColor)

            }
            }
            
            //-----------------------------------------------
            
            if !hideTabHub {
            if selectedTab == .HUB {

                    Button {
                        selectedTab = .HUB
                    } label: {
                        SymbolButton(bIcon: "h.square.fill", bTxt: "Hub")
                    }.foregroundColor(ForeColor)

            } else {

                Button {
                    selectedTab = .HUB
                } label: {
                    SymbolButton(bIcon: "h.square", bTxt: "")
                }.foregroundColor(ForeColor)

            }
            }
                
            //-----------------------------------------------
            //Spacer()
            //-----------------------------------------------
            
            if !hideTabLog {
            if selectedTab == .Goals {

                    Button {
                        selectedTab = .Goals
                    } label: {
                        SymbolButton(bIcon: "checklist.checked", bTxt: "Log")
                    }.foregroundColor(ForeColor)

            } else {

                    Button {
                        selectedTab = .Goals
                    } label: {
                        SymbolButton(bIcon: "checklist.unchecked", bTxt: "")
                    }.foregroundColor(ForeColor)

            }
            }
            
            
            //-----------------------------------------------
            //Spacer()
            //-----------------------------------------------
            
            
            if !hideTabGraphs {
            if selectedTab == .Settings {

                    Button  {
                        selectedTab = .Settings
                    } label: {
                        SymbolButton(bIcon: "chart.xyaxis.line", bTxt: "Graphs")
                    }.foregroundColor(ForeColor)

            } else {

                    Button  {
                        selectedTab = .Settings
                    } label: {
                        SymbolButton(bIcon: "chart.xyaxis.line", bTxt: "")
                    }.foregroundColor(ForeColor)

            }
            }

            //-----------------------------------------------

            if !hideTabProtocolList {
            if selectedTab == .ProtocolList {

                    Button {
                        selectedTab = .ProtocolList
                    } label: {
                        SymbolButton(bIcon: "list.bullet.rectangle.fill", bTxt: "Protocols")
                    }.foregroundColor(ForeColor)

            } else {

                    Button {
                        selectedTab = .ProtocolList
                    } label: {
                        SymbolButton(bIcon: "list.bullet.rectangle", bTxt: "")
                    }.foregroundColor(ForeColor)

            }
            }

            //-----------------------------------------------

            if !hideTabTest {
            if selectedTab == .Test {

                    Button {
                        selectedTab = .Test
                    } label: {
                        SymbolButton(bIcon: "t.square.fill", bTxt: "Test")
                    }.foregroundColor(ForeColor)

            } else {

                    Button {
                        selectedTab = .Test
                    } label: {
                        SymbolButton(bIcon: "t.square", bTxt: "")
                    }.foregroundColor(ForeColor)

            }
            }



            //-----------------------------------------------
            Spacer()
            //-----------------------------------------------
            
        }
        .colorScheme(.light)
        .foregroundColor(ForeColor)
//        .background(Rectangle()
//            .foregroundColor(BackColor))
        
        
        
        
    }
}

//#Preview {
//    TabBar(selectedTab: .Calendar)
//}
