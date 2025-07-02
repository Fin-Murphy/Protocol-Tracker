//
//  HabitDetailView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/1/25.
//

import SwiftUI

struct HabitDetailView: View {
    
    @Binding var habitNdx: Habit
    
    var body: some View {
       
        List{
            Text(habitNdx.HabitName)
                .font(.title)
                .padding()
            Text("Item is part of protocol \(habitNdx.HabitProtocol).")
            Text("Item start date: \(habitNdx.HabitStartDate, formatter: itemFormatter)" )
            Text("Item goal value: \(habitNdx.HabitGoal) \(habitNdx.HabitUnit)" )
            Text("Item repeats every \(habitNdx.HabitRepeatValue) days." )
            Text("Item Description: \n\n \(habitNdx.HabitDescription)" )
        }
        
        
        
        
    }
}

//#Preview {
//    HabitDetailView()
//}
