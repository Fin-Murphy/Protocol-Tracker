//
//  DateBarView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var SelectedDate: Date
    @State private var showingPicker = false
    
    var body: some View {
        Button(action: { showingPicker.toggle() }) {
            Text(SelectedDate, formatter: itemFormatter)
                .foregroundColor(ForeColor)
                .fontWeight(.bold)
                .font(.title2)
            
            
        }
        .sheet(isPresented: $showingPicker) {
            VStack {
                DatePicker("", selection: $SelectedDate)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Button("Done") {
                    showingPicker = false
                }
                .padding()
            }
        }
    }
}

struct DateBarView: View {
    
    @Binding var SelectedDate: Date
    @Binding var Celebrate: Int16
        
    var body: some View {
        VStack{
            HStack{
                
                Button {
                    SelectedDate = calendar.date(byAdding: .day, value: -1, to: SelectedDate)!
                } label: {
                    Text("<<")
                        .fontWeight(.bold)
                        .font(.title2)
                }
                
//                DatePicker("\(SelectedDate, formatter: itemFormatter)",
//                           selection: $SelectedDate,
//                           displayedComponents: .date)
//                .foregroundColor(ForeColor)
//                .datePickerStyle(.compact)
                
                CustomDatePicker(SelectedDate: $SelectedDate)
                
                
//                Text("\(SelectedDate, formatter: itemFormatter)")
//                    .fontWeight(.bold)
//                    .font(.title2)
                
                Text("- (\(Celebrate)/\(UserDefaults.standard.integer(forKey: "dailyGoal")) Points)")
//                Text(" - (\(Celebrate) Points)")
                    .fontWeight(.bold)
                    .font(.title2)
                
                
                Button {
                    SelectedDate = calendar.date(byAdding: .day, value: 1, to: SelectedDate)!
                    
                } label: {
                    Text(">>")
                        .fontWeight(.bold)
                        .font(.title2)
                }
            }
            .colorScheme(.light)
            .foregroundColor(ForeColor)
//            .onAppear {
//                Celebrate = Int16(UserDefaults.standard.integer(forKey:"TodayScore"))
//            }

            
        }
    }
}

