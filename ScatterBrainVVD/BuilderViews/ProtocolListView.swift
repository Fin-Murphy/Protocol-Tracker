//
//  ProtocolListView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/22/25.
//

import SwiftUI

struct ProtocolListView: View {
    
    @State var listOfProtocols: [HabitProtocol] = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
    @State var listOfHabits: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []
    
    var body: some View {
        
        Text("Protocols")
            .fontWeight(.bold)
            .font(.title)
            .padding(.bottom)
        
        NavigationView {
            List {
                
                ForEach(listOfProtocols) { prot in
                    
                    NavigationLink{
                        
                        VStack{
                            
                            Text(prot.ProtocolName)
                            
                            List{
                                ForEach(listOfHabits){ hab in
                                    
                                    if hab.HabitProtocol == prot.ProtocolName {
                                        Text(hab.HabitName)
                                    } else {}
                                    
                                }
                            }
                        }
                        
                    } label: {
                        Text(prot.ProtocolName)
                    } // End navlinklabel
                    
                } // End foreach
                
            } // End list
            
        }// End navview
        
    } // end body
    
    
    
    
    
}

#Preview {
    ProtocolListView()
}
