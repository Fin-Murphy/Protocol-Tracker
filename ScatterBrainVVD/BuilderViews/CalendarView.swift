//
//  CalendarView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI

struct CalendarView: View {
    
    @Binding var SelectedDate: Date
    @Binding var selectedTab: Tabs
    
    var body: some View {
        
    

        VStack{
           
            Button {SelectedDate = Date() } label: {Text("Current Date: \(Date(), formatter: itemFormatter)") }
            
            LazyHStack{
                
                ScrollView() {
                    LazyVStack {
                        ForEach(backward_Calendar, id: \.self){ day in
                            
                            Button{
                                SelectedDate = day
                                selectedTab = .HUB
                            } label: {
                                Text("\(day, formatter: itemFormatter)    ")
                            }
                        }
                    }.padding()
                }
                
                ScrollView() {
                    LazyVStack {
                        ForEach(forward_Calendar, id: \.self){ day in
                            
                            Button{
                                SelectedDate = day
                                selectedTab = .HUB
                            } label: {
                                Text("\(day, formatter: itemFormatter)    ")
                            }
                        }
                    }.padding()
                }
                
                
            } // END LAZY HSTACK
        }
        
        
        
        
    }
}

//#Preview {
//    CalendarView()
//}
