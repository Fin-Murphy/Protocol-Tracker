//
//  SettingsView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 8/18/25.
//

import SwiftUI

struct SettingsView: View {
    
    @State var DailyGoalSet: Int = UserDefaults.standard.integer(forKey: "dailyGoal")
    @State var NotifFreq: Int = UserDefaults.standard.integer(forKey: "notifFreq")

    var body: some View {
        
        VStack{

            HStack{
                Text("Settings")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding(.bottom)
            }.foregroundColor(ForeColor)
            
            Spacer()
            
            VStack{
                Text("Set daily goal")
                TextField("", value: $DailyGoalSet, format: .number)
                Button {
                    UserDefaults.standard.set(DailyGoalSet, forKey: "dailyGoal")
                } label : {
                    Text("Save daily goal")
                        .bckMod()
                }
                
            }.bckMod()
            
            VStack{
                Text("Notfication Frequency (hours)")
                TextField("Once every ___ hours", value: $NotifFreq, format: .number)
                Button {
                    if NotifFreq > 24 {
                        NotifFreq = 24
                    } else if NotifFreq < 1 {
                        NotifFreq = 1
                    }
                    UserDefaults.standard.set(NotifFreq, forKey: "notifFreq")
                } label : {
                    Text("Save Notificiation Frequency")
                        .bckMod()
                }
                
            }.bckMod()
            
            Spacer()
        }
        
        
    }
}

#Preview {
    SettingsView()
}
