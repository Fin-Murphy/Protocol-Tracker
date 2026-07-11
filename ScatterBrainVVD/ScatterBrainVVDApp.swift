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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [habItem.self, listItem.self, taskItem.self, dayScore.self])
        }
    }
}
