//
//  GraphTabView.swift
//  ScatterBrainVVD
//

import SwiftUI
import CoreData
import Charts

struct DayPoint: Identifiable {
    let id: UUID = UUID()
    let day: Date
    let value: Int16
    let complete: Bool
}

struct GraphTabView: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.order, ascending: true)],
        animation: .default)
    private var habitData: FetchedResults<HabitItem>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var itemData: FetchedResults<Item>

    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext

    // The last 7 days, oldest first, ending today
    private var weekDays: [Date] {
        let todayStart = Calendar.current.startOfDay(for: Date())
        return (0 ... 6).reversed().map {
            Calendar.current.date(byAdding: .day, value: -$0, to: todayStart)!
        }
    }

    var body: some View {

        Text("Graphs")
            .fontWeight(.bold)
            .font(.title)
            .padding(.bottom)
            .foregroundColor(ForeColor)

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                ForEach(habitData) { habit in

                    VStack(alignment: .leading) {

                        Text(habit.name ?? "")
                            .fontWeight(.bold)
                            .foregroundColor(ForeColor)

                        if habit.hasCheckbox {
                            checkboxRow(points: weekPoints(for: habit))
                        } else {
                            lineGraph(points: weekPoints(for: habit))
                        }

                    }
                    .bckMod()

                } // End foreach

            }
            .padding()
        } // End scrollview

    } // end body

    // ---------------------------------------------------------------------------------------------------------------------
    // GRAPH VIEWS
    // ---------------------------------------------------------------------------------------------------------------------

    private func checkboxRow(points: [DayPoint]) -> some View {
        HStack {
            ForEach(points) { point in
                VStack {
                    Image(systemName: point.complete ? "checkmark.square.fill" : "square")
                        .font(.title2)
                    Text(point.day, format: .dateTime.weekday(.abbreviated))
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundColor(ForeColor)
    }

    private func lineGraph(points: [DayPoint]) -> some View {
        Chart(points) { point in
            LineMark(
                x: .value("Day", point.day, unit: .day),
                y: .value("Value", Int(point.value))
            )
            PointMark(
                x: .value("Day", point.day, unit: .day),
                y: .value("Value", Int(point.value))
            )
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .frame(height: 150)
    }

    // ---------------------------------------------------------------------------------------------------------------------
    // DATA SHAPING
    // ---------------------------------------------------------------------------------------------------------------------

    private func weekPoints(for habit: HabitItem) -> [DayPoint] {
        weekDays.map { day in
            let match = itemData.first { item in
                baseName(item.name) == (habit.name ?? "") &&
                Calendar.current.isDate((item.timestamp ?? Date.distantPast), equalTo: day, toGranularity: .day)
            }
            return DayPoint(day: day, value: match?.value ?? 0, complete: match?.complete ?? false)
        }
    }

    // Items moved to tomorrow get renamed with a "> " prefix by scootItem(); strip it so they still match their habit
    private func baseName(_ name: String?) -> String {
        var trimmed = name ?? ""
        while trimmed.hasPrefix("> ") {
            trimmed = String(trimmed.dropFirst(2))
        }
        return trimmed
    }

}

#Preview {
    GraphTabView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
