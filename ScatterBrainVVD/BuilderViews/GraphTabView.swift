//
//  GraphTabView.swift
//  ScatterBrainVVD
//

import SwiftUI
import SwiftData

struct DayPoint: Identifiable {
    let id: UUID = UUID()
    let day: Date
    let complete: Bool
}

struct GraphTabView: View {

    @Query(sort: \habItem.order, animation: .default)
    private var habitData: [habItem]

    @Query(sort: \listItem.timestamp, animation: .default)
    private var itemData: [listItem]

    // 0 = the week ending today; negative values page back through history
    @State private var weekOffset: Int = 0

    // 7 days, oldest first, ending on the anchor day set by weekOffset
    private var weekDays: [Date] {
        let end = calendar.date(byAdding: .day, value: weekOffset * 7, to: calendar.startOfDay(for: Date()))!
        return (0 ... 6).reversed().map {
            calendar.date(byAdding: .day, value: -$0, to: end)!
        }
    }

    var body: some View {

        Text("Graphs")
            .fontWeight(.bold)
            .font(.title)
            .padding(.bottom)
            .foregroundColor(ForeColor)

        HStack {

            Button {
                weekOffset -= 1
            } label: {
                Text("<<")
                    .fontWeight(.bold)
                    .font(.title2)
            }

            Text("\(weekDays.first!, format: .dateTime.month(.abbreviated).day()) - \(weekDays.last!, format: .dateTime.month(.abbreviated).day())")
                .fontWeight(.bold)
                .font(.title2)

            Button {
                weekOffset += 1
            } label: {
                Text(">>")
                    .fontWeight(.bold)
                    .font(.title2)
            }
            .disabled(weekOffset == 0)

        }
        .foregroundColor(ForeColor)

        ScrollView {

            Grid(horizontalSpacing: 4, verticalSpacing: 6) {

                GridRow {
                    Text("")
                        .gridColumnAlignment(.leading)
                    ForEach(weekDays, id: \.self) { day in
                        VStack {
                            Text(day, format: .dateTime.weekday(.abbreviated))
                            Text(day, format: .dateTime.day())
                        }
                        .font(.caption)
                    }
                }

                ForEach(habitData) { habit in
                    GridRow {
                        Text(habit.name)
                            .lineLimit(1)
                        ForEach(weekPoints(for: habit)) { point in
                            Image(systemName: point.complete ? "checkmark.square.fill" : "square")
                                .font(.title3)
                        }
                    }
                }

            }
            .foregroundColor(ForeColor)
            .bckMod()
            .padding()

        } // End scrollview

    } // end body

    // ---------------------------------------------------------------------------------------------------------------------
    // DATA SHAPING
    // ---------------------------------------------------------------------------------------------------------------------

    private func weekPoints(for habit: habItem) -> [DayPoint] {
        weekDays.map { day in
            let match = itemData.first { item in
                baseName(item.name) == habit.name &&
                Calendar.current.isDate(item.timestamp, equalTo: day, toGranularity: .day)
            }
            return DayPoint(day: day, complete: match?.complete ?? false)
        }
    }

    // Items moved to tomorrow get renamed with a "> " prefix by scootItem(); strip it so they still match their habit
    private func baseName(_ name: String) -> String {
        var trimmed = name
        while trimmed.hasPrefix("> ") {
            trimmed = String(trimmed.dropFirst(2))
        }
        return trimmed
    }

}

#Preview {
    GraphTabView().modelContainer(for: [habItem.self, listItem.self, taskItem.self, dayScore.self], inMemory: true)
}
