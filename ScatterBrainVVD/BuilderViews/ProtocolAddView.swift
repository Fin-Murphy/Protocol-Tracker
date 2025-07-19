//
//  ProtocolAddView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/19/25.
//

import SwiftUI

struct ProtocolAddView: View {
    
    @State var protocolArray: [HabitProtocol] = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
    
    var body: some View {
        Text("Protocols")
            .fontWeight(.bold)
            .font(.title)
            .padding(.bottom)
        
//        Text("Protocols are pre-loaded sets of habits that you can quick-add to jumpstart your self-improvement routines")
//            .bckMod()
//            .padding()
        
        NavigationView{
            
            List{
                Text("User defined protocols:")
                    .fontWeight(.bold)
                
                ForEach(protocolArray){unit in
                    
                    Text(unit.ProtocolName)
                    
                }
                Text("App defined protocols:")
                    .fontWeight(.bold)
                
                ForEach(AppDefinedProtocols){unit in
                    NavigationLink{
                        Text(unit.ProtocolName)
                        ForEach(unit.ProtocolUnits){subUnit in
                            
                            Text(subUnit.HabitName)
                        }
                        

                    } label: {
                        Text(unit.ProtocolName)

                    }
                
                }
                
                
            }
        }
        
        Spacer()
        
        
    }
}

#Preview {
    ProtocolAddView()
}
