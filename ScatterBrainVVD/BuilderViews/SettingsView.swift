//
//  SettingsView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 8/18/25.
//

import SwiftUI

struct SettingsView: View {
    
    @State var DailyGoalSet: Int = UserDefaults.standard.integer(forKey: "dailyGoal")
    
    var body: some View {
        
        VStack{
//            
            HStack{
                Text("Settings")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding(.bottom)
            }.foregroundColor(ForeColor)
//            
            Spacer()
//            
            VStack{
                Text("Set daily goal")
                TextField("", value: $DailyGoalSet, format: .number)
                Button {
                    UserDefaults.standard.set(DailyGoalSet, forKey: "dailyGoal")
                } label : {
                    Text("Save daily goal")
                        .bckMod()
                }
//                
            }.bckMod()
//            
            Spacer()
        }
        
        
    }
}

#Preview {
    SettingsView()
}
