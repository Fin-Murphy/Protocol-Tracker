//
//  SymbolButton.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/21/25.
//

import SwiftUI

struct SymbolButton: View {

    var bIcon: String
    var bTxt: String
    var ButtColor:Int = 0
    
    var body: some View {
        
        VStack (alignment: .center, spacing:4){
            Image(systemName: bIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 24,height: 24)
                
            Text(bTxt).frame(width: 70,height: 17).font(.caption)
                
        }
        
        
    }
    
}

#Preview {
    SymbolButton(bIcon: "dumbbell.fill", bTxt: "Strength")
}
