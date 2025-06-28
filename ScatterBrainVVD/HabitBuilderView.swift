//
//  HabitBuilderView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI

struct HabitBuilderView: View {
    
    @State var HabitNameSet: String = ""
    @State var HabitGoalSet: Int16 = 1
    @State var HabitProtocolSet: String = "Daily"
    @State var HabitUnitSet: String = "units"
    @State var HabitRepetitionSet: Int = 1
    @State var HabitDescriptionSet: String = "This is a Habit"
    @State var HabitHasStatusSet: Bool = false
    @State var HabitRewardSet: Int = 1
    @State var HabitStartDateSet: Date = Date()
    @State var HabitIsSubtaskSet: Bool = false
    @State var HabitHasCheckboxSet: Bool = true
    
    
    
    
    
    
    
    
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    HabitBuilderView()
}
