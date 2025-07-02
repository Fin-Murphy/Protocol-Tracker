//
//  HabitEditView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/1/25.
//

import SwiftUI

struct HabitEditView: View {
    
    @Binding var habit: Habit
    @Binding var lister: [Habit]
    
    @State var HabitNameSet: String = ""
    @State var HabitGoalSet: Int16 = 1
    @State var HabitProtocolSet: String = "Daily"
    @State var HabitUnitSet: String = "units"
    
    @State var HabitRepetitionSet: Int = 1
    @State var HabitDescriptionSet: String = "This is a Habit"
    @State var HabitHasStatusSet: Bool = false
    @State var HabitRewardSet: Int16 = 1
    
    @State var HabitStartDateSet: Date = Date()
    @State var HabitIsSubtaskSet: Bool = false
    @State var HabitHasCheckboxSet: Bool = true
    
    
    var body: some View {
        
        
        Form {
            
            Section(header: Text("Habit Name:")) {
                TextField("", text: $HabitNameSet)
            }
            Toggle("Use checkbox instead of units",isOn: $HabitHasCheckboxSet)
            if HabitHasCheckboxSet == false {
                Section(header: Text("Habit Goal:")) {
                    TextField("", value: $HabitGoalSet, format: .number)
                }
                Section(header: Text("Habit Unit:")) {
                    TextField("", text: $HabitUnitSet)
                }
            }
            Section(header: Text("Habit Protocol:")) {
                TextField("", text: $HabitProtocolSet)
            }
            Section(header: Text("Habit Interval (1 = Daily, 7 = Weekly, etc):")) {
                TextField("", value: $HabitRepetitionSet, format: .number)
            }
            Section(header: Text("Habit Details")) {
                TextEditor(text: $HabitDescriptionSet)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            Section("Habit Start Date") {
                DatePicker("Select Date",
                           selection: $HabitStartDateSet,
                           displayedComponents: .date)
                .datePickerStyle(.compact)
            }
            Section(header: Text("Habit Reward (Points for completion)")) {
                TextField("", value: $HabitRewardSet, format: .number)
            }
            Toggle("Include status update", isOn: $HabitHasStatusSet)
            Toggle("Make this habit a subtask of another habit?", isOn: $HabitIsSubtaskSet)
            
            
            Section {
                Button {
                    
                    habit.HabitName = HabitNameSet
                    habit.HabitGoal = HabitGoalSet
                    habit.HabitUnit = HabitUnitSet
                    habit.HabitProtocol = HabitProtocolSet
                    habit.HabitRepeatValue = HabitRepetitionSet
                    habit.HabitDescription = HabitDescriptionSet
                    habit.HabitStartDate = HabitStartDateSet
                    habit.HabitReward = HabitRewardSet
                    habit.HabitHasStatus = HabitHasStatusSet
                    habit.HabitHasCheckbox = HabitHasCheckboxSet
                    
                } label: {Text("Save Habit")}
                
                
            }
            
        }
        .onAppear{
            
            HabitNameSet = habit.HabitName
            HabitGoalSet = habit.HabitGoal
            HabitUnitSet = habit.HabitUnit
            HabitProtocolSet = habit.HabitProtocol
            HabitRepetitionSet = habit.HabitRepeatValue
            HabitDescriptionSet = habit.HabitDescription
            HabitStartDateSet = habit.HabitStartDate
            HabitRewardSet = habit.HabitReward
            HabitHasCheckboxSet = habit.HabitHasCheckbox
            HabitHasStatusSet = habit.HabitHasStatus
            
        }
    }
}

//#Preview {
//    HabitEditView()
//}
