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
                    }.foregroundColor(.black)

            } else {

                    Button {
                        selectedTab = .Calendar
                    }
                    label: {
                        SymbolButton(bIcon: "calendar", bTxt: "")
                    }.foregroundColor(.black)

            }
            
            //-----------------------------------------------
            //Spacer()
            //-----------------------------------------------
            
                
            //-----------------------------------------------

            if selectedTab == .HUB {
                
                    Button {
                        selectedTab = .HUB
                    } label: {
                        SymbolButton(bIcon: "h.square.fill", bTxt: "Hub")
                    }.foregroundColor(.black)
                
            } else {
                
                Button {
                    selectedTab = .HUB
                } label: {
                    SymbolButton(bIcon: "h.square", bTxt: "")
                }.foregroundColor(.black)
                
            }

            //-----------------------------------------------
            
            if selectedTab == .Protocols {
                
                    Button {
                        selectedTab = .Protocols
                    } label: {
                        SymbolButton(bIcon: "arrowtriangle.down.square.fill", bTxt: "Habits")
                    }.foregroundColor(.black)
                
            } else {
                    
                    Button {
                        selectedTab = .Protocols
                    } label: {
                        SymbolButton(bIcon: "arrowtriangle.down.square", bTxt: "")
                    }.foregroundColor(.black)
            
            }
                
            //-----------------------------------------------
            //Spacer()
            //-----------------------------------------------
            
            if selectedTab == .Goals {
                
                    Button {
                        selectedTab = .Goals
                    } label: {
                        SymbolButton(bIcon: "checklist.checked", bTxt: "Tasks")
                    }.foregroundColor(.black)
                
            } else {
                    
                    Button {
                        selectedTab = .Goals
                    } label: {
                        SymbolButton(bIcon: "checklist.unchecked", bTxt: "")
                    }.foregroundColor(.black)
            
            }
            
            
            //-----------------------------------------------
            //Spacer()
            //-----------------------------------------------
            
            
            if selectedTab == .Settings {

                    Button  {
                        selectedTab = .Settings
                    } label: {
                        SymbolButton(bIcon: "gearshape.fill", bTxt: "Settings")
                    }.foregroundColor(.black)

            } else {

                    Button  {
                        selectedTab = .Settings
                    } label: {
                        SymbolButton(bIcon: "gearshape", bTxt: "")
                    }.foregroundColor(.black)

            }
            
     
                
            //-----------------------------------------------
            Spacer()
            //-----------------------------------------------
            
        }
        .colorScheme(.light)
        .background(Rectangle()
            .foregroundColor(.white))
        
        
        
        
    }
}

//#Preview {
//    TabBar(selectedTab: .Calendar)
//}
