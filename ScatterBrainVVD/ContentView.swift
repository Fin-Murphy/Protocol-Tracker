//
//  ContentView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/20/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    
    @State var DisplayHabitMaker: Bool = false
    @State var DisplayTaskMaker: Bool = false

    @State var Today = Date()
    @State var SelectedDate: Date = Date()
    
    let valueRange = 1 ... 10
    let calendar = Calendar(identifier: .gregorian)
    
    @State var HabitNameSet: String = ""
    @State var HabitValueSet: Int16 = 0
    @State var HabitGoalSet: Int16 = 1
    @State var HabitProtocolSet: String = "Daily"
    @State var HabitUnitSet: String = "units"
    @State var HabitRepetitionSet: Int = 1
    @State var HabitDescriptionSet: String = "This is a Habit"
    @State var HabitHasStatusSet: Bool = false
    @State var HabitRewardSet: Int = 1
    @State var HabitStartDateSet: Date = Date()
    
    @State var TaskNameSet: String = ""
    @State var TaskDescriptionSet: String = "This is a Task"
    @State var TaskRewardSet: Int16 = 1
    @State var TaskDueDateSet: Date = Date()
    @State var TaskUnitSet: String = "units"
    @State var TaskGoalSet: Int16 = 1
    
    @State var Celebrate: Int16 = 0
    
    @State var updateItemStatus: Int16 = 0

    //-------------------------------------------
    @State var range:Int = 4
    //----------------------------------------------------------
    
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }
    
/*    ------------------------------------------------
    
               BEGIN PRIVATE FUNCTIONS
    
 ------------------------------------------------     */
    
        
    /*    ------------------------------------------------
                   ADD ITEM
     ------------------------------------------------     */
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    /*    ------------------------------------------------
                   DELETE ITEM
     ------------------------------------------------     */
    
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
