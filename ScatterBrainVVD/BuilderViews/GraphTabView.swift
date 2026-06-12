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

struct UnifiedPoint: Identifiable {
    let id: UUID = UUID()
    let habitName: String
    let day: Date
    let percent: Double
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

    @State private var unifiedGraph: Bool = false
    @State private var habitColors: [String: Color] = [:]

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

        Toggle("Unified Graph", isOn: $unifiedGraph)
            .foregroundColor(ForeColor)
            .padding(.horizontal)

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if unifiedGraph {

                    unifiedLineGraph()
                        .bckMod()

                } else {

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

            }
            .padding()
        } // End scrollview
        .onAppear(perform: assignColors)
        .onChange(of: habitData.count) { assignColors() }

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

    private func unifiedLineGraph() -> some View {
        let names = habitData.map { $0.name ?? "" }
        return Chart(unifiedPoints()) { point in
            LineMark(
                x: .value("Day", point.day, unit: .day),
                y: .value("Percent", point.percent)
            )
            .foregroundStyle(by: .value("Habit", point.habitName))
            PointMark(
                x: .value("Day", point.day, unit: .day),
                y: .value("Percent", point.percent)
            )
            .foregroundStyle(by: .value("Habit", point.habitName))
        }
        .chartForegroundStyleScale(domain: names, range: names.map { habitColors[$0] ?? .gray })
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let percent = value.as(Double.self) {
                        Text("\(Int(percent))%")
                    }
                }
            }
        }
        .frame(height: 250)
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

    private func unifiedPoints() -> [UnifiedPoint] {
        habitData.flatMap { habit in
            weekPoints(for: habit).map { point in
                UnifiedPoint(habitName: habit.name ?? "", day: point.day, percent: percent(point, for: habit))
            }
        }
    }

    // Checkbox habits (and any habit without a goal to divide by) are all-or-nothing: 100% or 0%
    private func percent(_ point: DayPoint, for habit: HabitItem) -> Double {
        if habit.hasCheckbox || habit.goal <= 0 {
            return point.complete ? 100 : 0
        }
        return Double(point.value) / Double(habit.goal) * 100
    }

    private func assignColors() {
        for habit in habitData {
            let name = habit.name ?? ""
            if habitColors[name] == nil {
                habitColors[name] = Color(hue: .random(in: 0 ... 1), saturation: 0.8, brightness: 0.9)
            }
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
