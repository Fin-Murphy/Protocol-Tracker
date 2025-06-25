//
//  PracticeView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/25/25.
//

import SwiftUI

struct PracticeView: View {
    
    @State private var items: [Habit] = UserDefaults.standard.getDecodable([Habit].self, forKey: "habitList") ?? []

      var body: some View {
          NavigationView {
              List {
                  ForEach(items, id: \.self) { item in
                      Text(item.HabitName)
                  }
                  .onMove(perform: move)
              }
              .toolbar {
                  EditButton()
              }
          }
      }

      private func move(from source: IndexSet, to destination: Int) {
          items.move(fromOffsets: source, toOffset: destination)
          print(items)
          UserDefaults.standard.setEncodable(items, forKey: "habitList")
      }
    
    
    
}

#Preview {
    PracticeView()
}
