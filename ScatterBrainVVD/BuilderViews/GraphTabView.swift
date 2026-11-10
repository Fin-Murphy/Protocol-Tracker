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
    // View-only: whether the habit had an item on that day's list at all
    let scheduled: Bool
}

struct GraphTabView: View {

    @Query(sort: \habItem.order, animation: .default)
    private var habitData: [habItem]

    @Query(sort: \listItem.timestamp, animation: .default)
    private var itemData: [listItem]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // 0 = the week ending today; negative values page back through history
    @State private var weekOffset: Int = 0

    // 7 days, oldest first, ending on the anchor day set by weekOffset
    private var weekDays: [Date] {
        let end = calendar.date(byAdding: .day, value: weekOffset * 7, to: calendar.startOfDay(for: Date()))!
        return (0 ... 6).reversed().map {
            calendar.date(byAdding: .day, value: -$0, to: end)!
        }
    }

    private let cellFont = Font.system(.caption, design: .monospaced, weight: .medium)

    @ViewBuilder
    private func cell(_ point: DayPoint, colorName: String) -> some View {
        Group {
            if point.complete {
                Circle()
                    .fill(habitColor(colorName))
                    .frame(width: 18, height: 18)
            } else if point.scheduled {
                Circle()
                    .stroke(Theme.control, lineWidth: 1.5)
                    .frame(width: 18, height: 18)
            } else {
                Circle()
                    .fill(Theme.separator)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(width: 28, height: 28)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(point.day.formatted(.dateTime.weekday(.wide))), \(point.complete ? "done" : (point.scheduled ? "not done" : "not on the list"))")
    }

    var body: some View {

        VStack(spacing: 0) {

            ScreenHeader(title: "Graphs")

            HStack {

                IconButton(systemName: "chevron.left", label: "Previous week") {
                    weekOffset -= 1
                }

                Spacer()

                Text("\(weekDays.first!, format: .dateTime.day().month(.abbreviated)) – \(weekDays.last!, format: .dateTime.day().month(.abbreviated))")
                    .font(Theme.value)
                    .foregroundStyle(Theme.text1)

                Spacer()

                IconButton(systemName: "chevron.right", label: "Next week") {
                    weekOffset += 1
                }
                .disabled(weekOffset == 0)

            }
            .padding(.horizontal, 8)

            if habitData.isEmpty {

                EmptyState(symbol: "chart.dots.scatter",
                           title: "Nothing to chart",
                           sentence: "Add a habit and its week appears here.")

            } else {

                ScrollView {

                    Grid(horizontalSpacing: 4, verticalSpacing: 0) {

                        GridRow {
                            Color.clear
                                .gridCellUnsizedAxes([.horizontal, .vertical])
                            ForEach(weekDays, id: \.self) { day in
                                VStack(spacing: 2) {
                                    Text(day, format: .dateTime.weekday(.narrow))
                                    Text(day, format: .dateTime.day())
                                }
                                .font(cellFont)
                                .foregroundStyle(calendar.isDateInToday(day) ? Theme.accent : Theme.text2)
                                .frame(width: 28)
                                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(day.formatted(.dateTime.weekday(.wide).day()))
                                .accessibilityShowsLargeContentViewer {
                                    Text(day, format: .dateTime.weekday(.abbreviated).day())
                                }
                            }
                        }
                        .padding(.bottom, 4)

                        ForEach(habitData) { habit in
                            if dynamicTypeSize.isAccessibilitySize {
                                // Large text: the name gets its own full-width line above its cells
                                Text(habit.name)
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.text1)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .gridCellColumns(8)
                                    .padding(.top, 8)
                                GridRow {
                                    Color.clear
                                        .gridCellUnsizedAxes([.horizontal, .vertical])
                                    ForEach(weekPoints(for: habit)) { point in
                                        cell(point, colorName: habit.colorName)
                                    }
                                }
                            } else {
                                GridRow {
                                    Text(habit.name)
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.text1)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(minWidth: 96, maxWidth: .infinity, alignment: .leading)
                                    ForEach(weekPoints(for: habit)) { point in
                                        cell(point, colorName: habit.colorName)
                                    }
                                }
                                .frame(minHeight: 44)
                            }
                        }

                    }
                    .card()
                    .padding(16)

                } // End scrollview
            }
        }
        .background(Theme.bg)

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
            return DayPoint(day: day, complete: match?.complete ?? false, scheduled: match != nil)
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
