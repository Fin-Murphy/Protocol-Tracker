//
//  ScatterBrainVVDApp.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/20/25.
//

import SwiftUI
import SwiftData

@main
struct ScatterBrainVVDApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .modelContainer(for: habItem.self)
        }
    }
}
