//
//  GoalSetView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/27/25.
//

import SwiftUI

struct GoalSetView: View {
    
    @State var dailyGoalSet: Int?
    @State var displayCompletedHabits: Bool = false
    var body: some View {
      
        VStack {
            HStack {
                Text("Set your daily goal:")
                
                TextField("", value: $dailyGoalSet, format: .number)
                    .frame(maxWidth: 100, alignment: .center)
            }.ignoresSafeArea(.keyboard)
                .padding()
                .foregroundColor(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 3)
                )
                .cornerRadius(10)
            
            Button {
                UserDefaults.standard.set(dailyGoalSet, forKey: "dailyGoal")
            } label: {
                Text("Save Daily Goal")
            }
            .foregroundColor(.blue)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 3)
            )
            .cornerRadius(10)
            
            Toggle("Move complete habits to bottom of list",isOn: $displayCompletedHabits)
                .onAppear{displayCompletedHabits = UserDefaults.standard.bool(forKey: "displayCompletedHabits")}
                .onChange(of: displayCompletedHabits) {
                    UserDefaults.standard.set(displayCompletedHabits, forKey: "displayCompletedHabits")
                }
            
        }
        .onAppear{dailyGoalSet = UserDefaults.standard.integer(forKey: "dailyGoal")}
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 3)
        )
        .cornerRadius(10)
        
        
        
        
        
        
        
        
        
        
    }
}

#Preview {
    GoalSetView()
}
