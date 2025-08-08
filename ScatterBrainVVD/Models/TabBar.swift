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
}


struct TabBar: View {
    
    @Binding var selectedTab: Tabs
    
    
    var body: some View {
       
        HStack {
            
            //-----------------------------------------------
            Spacer()
            //-----------------------------------------------
            
            if selectedTab == .Calendar {

                    Button {
                        selectedTab = .Calendar
                    }
                    label: {
                        SymbolButton(bIcon: "calendar.badge.plus", bTxt: "Calendar")
                    }.foregroundColor(ForeColor)

            } else {

                    Button {
                        selectedTab = .Calendar
                    }
                    label: {
                        SymbolButton(bIcon: "calendar", bTxt: "")
                    }.foregroundColor(ForeColor)

            }
            
            //-----------------------------------------------
            //Spacer()
            //-----------------------------------------------
            
        
            //-----------------------------------------------
            
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
            
            //-----------------------------------------------
            
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
                
            //-----------------------------------------------
            //Spacer()
            //-----------------------------------------------
            
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
            
            
            //-----------------------------------------------
            //Spacer()
            //-----------------------------------------------
            
            
            if selectedTab == .Settings {

                    Button  {
                        selectedTab = .Settings
                    } label: {
                        SymbolButton(bIcon: "gearshape.fill", bTxt: "Settings")
                    }.foregroundColor(ForeColor)

            } else {

                    Button  {
                        selectedTab = .Settings
                    } label: {
                        SymbolButton(bIcon: "gearshape", bTxt: "")
                    }.foregroundColor(ForeColor)

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
