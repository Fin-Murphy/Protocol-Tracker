//
//  ProtocolListView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/22/25.
//

import SwiftUI
import SwiftData

struct ProtocolListView: View {

    @Query(sort: \habItem.name, animation: .default)
    private var habitData: [habItem]
    
    @State var listOfProtocols: [HabitProtocol] = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
    @State var displayProtocolLibrary: Bool = false
    
    var body: some View {
        HStack {
            Text("Protocols")
                .fontWeight(.bold)
                .font(.title)
                .padding(.bottom)
            
            Button {
                displayProtocolLibrary = true
            } label: {
                Text("+")
                    .font(.title)
                    .padding(.bottom)
            }
        }.foregroundColor(ForeColor)
        
        ZStack {

            NavigationView {
                List {

                    ForEach(listOfProtocols) { prot in

                        NavigationLink{

                            VStack{

                                Text(prot.ProtocolName)

                                List{
                                    ForEach(habitData){ hab in
                                        
                                        if hab.whichProtocol == prot.ProtocolName {
                                            Text(hab.name)
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
            
            if displayProtocolLibrary {
                ProtocolLibraryModal(isPresented: $displayProtocolLibrary, onIncorporate: {
                    listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
                })
            } else {}

        }// End Zstack


    } // end body
}

#Preview {
    ProtocolListView()
}
