//
//  HabitItemComponent.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import CoreData

struct HabitItemComponent: View {
    
    @Environment var inItem: Item
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
        
    @Binding var Celebrate: Int16
        
    @State var updateItemStatus: Int16 = 0
    
    @State var habitData: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []

    
    
    
    var body: some View {
        
        NavigationLink {
            
            if inItem.complete == true {
                Text(String(inItem.name ?? ""))
                    .font(.title)
                    .fontWeight(.bold)
                    .strikethrough()
            } else {
                Text(String(inItem.name ?? ""))
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            if inItem.hasStatus == true {
                
                
                VStack {
                    HStack {
                        Text("Habit status:")
                        
                        TextField("", value: $updateItemStatus, format: .number)
                            .frame(maxWidth: 100, alignment: .center)
                    }.ignoresSafeArea(.keyboard)
                        .padding()
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .cornerRadius(10)
                    
                    Button {setStatus(refItem: inItem)} label: {
                        Text("Save Habit Status")
                        
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .cornerRadius(10)
                    
                }
                .onAppear{updateItemStatus = inItem.status}
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 3)
                )
                .cornerRadius(10)
                
            } else {}
            
            Spacer()
            
            ScrollView {
                if inItem.isTask != true {
                    
                    Text(displayHabitDescription(identifier: inItem.name ?? ""))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .cornerRadius(10)
                    
                } else {
                    
                    Text(inItem.descriptor ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .cornerRadius(10)
                }
                
                
            }.frame(width: 350)
            
            Spacer()
            
            // ---------------------- BEGIN VALUE MODIFICATION
            
            if inItem.hasCheckbox == false {
                
                if inItem.complete == true {
                    Text("☑ \(inItem.value)/\(inItem.goal) \(inItem.unit ?? "")")
                        .font(.title)
                        .padding()
                        .padding()
                    //.background(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .cornerRadius(10)
                } else {
                    Text("☐ \(inItem.value)/\(inItem.goal) \(inItem.unit ?? "")")
                        .font(.title)
                        .padding()
                        .padding()
                    //.background(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .cornerRadius(10)
                    
                }
                
                HStack{
                    
                    Button {
                        addOne(item: inItem)
                    }
                    label: {
                        Text("+ 1")
                            .shadow(radius: 5)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                            .cornerRadius(10)
                    }
                    Button {
                        subOne(item: inItem)
                        if inItem.value == inItem.goal {
                            
                        }
                    }
                    label: {
                        Text("- 1")
                            .shadow(radius: 5)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                            .cornerRadius(10)
                    }
                }
                
            } else {
                
                
                if inItem.complete == true {
                    Button{
                        subOne(item: inItem)
                    } label: {
                        Text("☑")
                            .font(.title)
                            .padding()
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                            .cornerRadius(10)
                    }
                    
                } else {
                    Button{
                        addOne(item: inItem)
                    } label: {
                        Text("☐")
                            .font(.title)
                            .padding()
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                            .cornerRadius(10)
                    }
                }
            }
            // ---------------------- END VALUE MODIFICATION
            
            
            Spacer()
            
        } label: {
            
            
            HStack{
                
                if inItem.isTask == true {
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
                
                if inItem.complete == true {
                    Text(String(inItem.name ?? ""))
                        .strikethrough()
                } else {
                    Text(String(inItem.name ?? ""))
                }
                Spacer()
                
                if inItem.complete == true {
                    Text("☑")
                } else {
                    Text("☐")
                }
                
                if inItem.hasCheckbox == false {
                    Text("\(inItem.value)/\(inItem.goal)")
                    Text("   ")
                }
            }
        }.onAppear{habitData = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []}
        
    }
    
    
    private func setStatus(refItem: Item) {
        refItem.status = updateItemStatus
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        print(refItem.status)
    }
    
    
    private func displayHabitDescription (identifier: String) -> String {
        
        for index in habitData {
            if index.HabitName == identifier {
                return index.HabitDescription
            }
        }
        return "No description"
    }


    /*    ------------------------------------------------
                    ADD ONE
     ------------------------------------------------     */
    
    private func addOne(item: Item) {
        
        if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {

            item.value = item.value + 1
            
            if item.value >= item.goal {
                if item.complete == false {
                    Celebrate += item.reward
                }
                item.complete = true
            }
            
            if Celebrate >= UserDefaults.standard.integer(forKey: "dailyGoal") {
                celebrationProcedure()
            }
        }
            

     
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    
    /*    ------------------------------------------------
                    SUB ONE
     ------------------------------------------------     */
    
    
    
    private func subOne(item: Item) {
        
        if Calendar.current.isDate((item.timestamp ?? Date()), equalTo: Date(), toGranularity: .day) == true {
            
            if item.value > 0 {
                item.value = item.value - 1
            }
            
            if item.value < item.goal {
                if item.complete == true {
                    Celebrate -= item.reward
                }
                item.complete = false
            }
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func celebrationProcedure () {
            print("Goal for the day has been completed!")
    }
    
    
    
    
    
}
