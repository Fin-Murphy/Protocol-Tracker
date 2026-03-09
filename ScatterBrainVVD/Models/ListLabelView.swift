//
//  ListLabelView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/1/25.
//

import SwiftUI

struct ListLabelView: View {

    @Binding var itemz: Item

    var body: some View {
        
        HStack{
            
            if itemz.isTask == true {
                Image(systemName: "t.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20,height: 20)
            } else {
                Image(systemName: "h.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20,height: 20)
            }
            
            if itemz.complete == true {
                Text(String(itemz.name ?? ""))
                    .strikethrough()
            } else {
                Text(String(itemz.name ?? ""))
            }
            Spacer()
            
            if itemz.complete == true {
                Text("☑")
            } else {
                Text("☐")
            }
            
            if itemz.hasCheckbox == false {
                Text("\(itemz.value)/\(itemz.goal)")
                Text("   ")
            }
        }
        
        
        
    }
}

//#Preview {
//    ListLabelView()
//}
