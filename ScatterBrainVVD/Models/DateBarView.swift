//
//  DateBarView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import SwiftData

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

    // All stored daily scores; we pick out the one matching SelectedDate so chevroning
    // through the calendar shows that day's point total. Today's record updates live as
    // habits are completed, so this re-renders automatically.
    @Query
    private var dayScores: [dayScore]

    private var displayedScore: Int {
        dayScores.first(where: {
            calendar.isDate($0.day, inSameDayAs: SelectedDate)
        })?.score ?? 0
    }

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
                
                Text("- (\(displayedScore)/\(UserDefaults.standard.integer(forKey: "dailyGoal")) Points)")
//                Text(" - (\(displayedScore) Points)")
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

