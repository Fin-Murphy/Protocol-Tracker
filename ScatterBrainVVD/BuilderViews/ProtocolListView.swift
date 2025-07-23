//
//  ProtocolListView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/22/25.
//

import SwiftUI

struct ProtocolListView: View {
    
    @State var listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
    
    
    var body: some View {
        
        List {
        
            ForEach(listOfProtocols) { prot in
                
                Text(prot.ProtocolName)
                
            }
        }
    }
}

#Preview {
    ProtocolListView()
}
