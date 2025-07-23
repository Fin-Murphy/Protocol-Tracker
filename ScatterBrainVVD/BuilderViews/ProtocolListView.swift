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
        }
        ZStack {
            
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
            
            if displayProtocolLibrary {
                VStack{
                    Button{
                        displayProtocolLibrary = false
                    } label: {
                        closeButton
                    }
                    .padding()
                    
                    NavigationView{
                        List{
                            
                       
                            ForEach(AppDefinedProtocolLibrary){adp in
                                NavigationLink{
                                    List{
                                        ForEach(adp.ProtocolContent){cont in
                                            Text(cont.HabitName)
                                        }
                                    }
                                } label: {
                                    Text(adp.ProtocolName)
                                }
                                
                                
                            }
                        }//end list
                    }// end navview
                                        
                    
                }
                .frame(width:300,height:700)
                .cornerRadius(10)
                .background(Rectangle()
                    .foregroundColor(.black))
                .cornerRadius(20)
                .shadow(radius: 20)
                
            } else {}
                
            
        }// End Zstack
        
        
        
        
        
    } // end body
    
    
    
    
    
}

#Preview {
    ProtocolListView()
}
