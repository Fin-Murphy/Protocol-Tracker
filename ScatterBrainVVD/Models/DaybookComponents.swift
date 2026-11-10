//
//  DaybookComponents.swift
//  ScatterBrainVVD
//
//  Reusable view pieces from DESIGN.md section 4, shared across the tab screens.
//

import SwiftUI

// ---------------------------------------------------------------------------------------------------------------------
// TEXT + HEADER PIECES
// ---------------------------------------------------------------------------------------------------------------------

struct SectionLabel: View {

    let text: String
    var color: Color = Theme.text2

    init(_ text: String, color: Color = Theme.text2) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text.uppercased())
            .font(Theme.sectionLabel)
            .tracking(1.0)
            .foregroundStyle(color)
    }
}

// The common header row at the root of every tab: serif title leading, icon buttons trailing
struct ScreenHeader<Trailing: View>: View {

    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(Theme.screenTitle)
                .foregroundStyle(Theme.text1)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            trailing
        }
        .frame(minHeight: 44)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(title: String) {
        self.init(title: title) { EmptyView() }
    }
}

struct IconButton: View {

    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(Theme.icon)
                .foregroundStyle(Theme.text1)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(FadeButtonStyle())
        .accessibilityLabel(label)
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// CARD ROWS
// ---------------------------------------------------------------------------------------------------------------------

// A labelled row inside a card: meta label left, value right; stacked at accessibility sizes
struct CardRow: View {

    let label: String
    let value: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) {
                    labelText
                    valueText
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    labelText
                    Spacer(minLength: 0)
                    valueText
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    private var labelText: some View {
        Text(label).font(Theme.meta).foregroundStyle(Theme.text2)
    }

    private var valueText: some View {
        Text(value).font(Theme.body).foregroundStyle(Theme.text1)
    }
}

// Stacks rows with 1pt separators between them and wraps them in a card
struct RowCard<Content: View>: View {

    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group(subviews: content) { subviews in
                ForEach(Array(subviews.enumerated()), id: \.offset) { index, subview in
                    if index > 0 {
                        Rectangle().fill(Theme.separator).frame(height: 1)
                    }
                    subview
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.separator, lineWidth: 1)
        )
    }
}

// A card holding one block of free text (descriptions, notes)
struct TextCard: View {

    let text: String

    var body: some View {
        Text(text)
            .font(Theme.body)
            .foregroundStyle(Theme.text1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// EMPTY STATE
// ---------------------------------------------------------------------------------------------------------------------

struct EmptyState: View {

    let symbol: String
    let title: String
    let sentence: String
    var buttonTitle: String? = nil
    var action: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: symbol)
                .font(.system(size: 32))
                .foregroundStyle(Theme.text3)
                .accessibilityHidden(true)
            Text(title)
                .font(Theme.button)
                .foregroundStyle(Theme.text1)
                .padding(.top, 12)
            Text(sentence)
                .font(Theme.meta)
                .foregroundStyle(Theme.text2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .padding(.top, 4)
            if let buttonTitle {
                Button(buttonTitle, action: action)
                    .buttonStyle(SecondaryButtonStyle(fullWidth: false))
                    .padding(.top, 16)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// CHECK CONTROL
// ---------------------------------------------------------------------------------------------------------------------

private struct CheckMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.27, y: rect.minY + rect.height * 0.53))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.44, y: rect.minY + rect.height * 0.69))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.74, y: rect.minY + rect.height * 0.34))
        return path
    }
}

// The bullet for a checklist item. Shape encodes type (habit = circle, task = rounded square);
// fill encodes state (outline, progress arc, or filled with a check mark).
struct CheckControl: View {

    var isTask: Bool
    var complete: Bool
    // nil = plain checkbox; otherwise value/goal for the progress arc
    var fraction: Double? = nil
    var colorName: String = "Default"
    var size: CGFloat = 26

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var shape: AnyShape {
        isTask ? AnyShape(RoundedRectangle(cornerRadius: size * 6 / 26, style: .continuous)) : AnyShape(Circle())
    }

    private var tint: Color { habitColor(colorName) }

    // Default-coloured habits (and all tasks) get the softer `control` outline when unchecked
    private var outline: Color {
        habitColorOptions.contains(colorName) && colorName != "Default" ? tint : Theme.control
    }

    var body: some View {
        ZStack {
            if let fraction, complete == false {
                shape.stroke(Theme.separator, lineWidth: 1.5)
                shape
                    .trim(from: 0, to: min(max(fraction, 0), 1))
                    .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: fraction)
            } else {
                shape.stroke(outline, lineWidth: 1.5)
                    .opacity(complete ? 0 : 1)
            }

            shape.fill(tint)
                .opacity(complete ? 1 : 0)

            CheckMark()
                .trim(from: 0, to: complete || reduceMotion ? 1 : 0)
                .stroke(Theme.bg, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .opacity(complete ? 1 : 0)
        }
        .frame(width: size, height: size)
        .animation(.easeOut(duration: reduceMotion ? 0.15 : 0.18), value: complete)
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// DOUBLE RULE
// ---------------------------------------------------------------------------------------------------------------------

// The signature element: the first line is the day's progress, the second is drawn only once
// the day's goal is met. Animate a change of `closed` to draw the closing rule left to right.
struct DoubleRule: View {

    var fraction: Double
    var closed: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 3) {
            Rectangle()
                .fill(Theme.separator)
                .frame(height: 2)
                .overlay(alignment: .leading) {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Theme.accent)
                            .frame(width: geo.size.width * min(max(fraction, 0), 1))
                            .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: fraction)
                    }
                }

            Rectangle()
                .fill(Theme.accent)
                .frame(height: 2)
                .scaleEffect(x: closed || reduceMotion ? 1 : 0, anchor: .leading)
                .opacity(closed ? 1 : 0)
        }
    }
}

// The 16pt pair that marks the selected tab
struct DoubleRuleMark: View {
    var body: some View {
        VStack(spacing: 3) {
            Rectangle().frame(width: 16, height: 2)
            Rectangle().frame(width: 16, height: 2)
        }
        .foregroundStyle(Theme.accent)
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// FORM PIECES
// ---------------------------------------------------------------------------------------------------------------------

extension View {
    // Native Form on the paper background with surface rows
    func daybookForm() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .foregroundStyle(Theme.text1)
    }

    // Standard chrome for a create/edit sheet: inline title, Cancel leading, Save trailing
    func formSheetToolbar(title: String, onCancel: @escaping () -> Void, onSave: @escaping () -> Void) -> some View {
        self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .fontWeight(.semibold)
                }
            }
    }
}

// Multi-line notes field used by every form
struct NotesEditor: View {

    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .frame(minHeight: 96)
            .scrollContentBackground(.hidden)
            .accessibilityLabel("Notes")
    }
}

// Row of eight habit-colour swatches
struct ColourSwatchRow: View {

    @Binding var selection: String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(habitColorOptions, id: \.self) { name in
                Button {
                    selection = name
                } label: {
                    Circle()
                        .fill(habitColor(name))
                        .frame(width: 28, height: 28)
                        .overlay {
                            if selection == name {
                                Circle()
                                    .stroke(Theme.text1, lineWidth: 2)
                                    .padding(-4)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(name)
                .accessibilityAddTraits(selection == name ? .isSelected : [])
            }
        }
    }
}

// Seven circular day chips, Sunday first (the order the dow model stores them in)
struct DayOfWeekChips: View {

    // Sunday ... Saturday
    let days: [Binding<Bool>]

    private let initials = ["S", "M", "T", "W", "T", "F", "S"]
    private let names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { ndx in
                Button {
                    days[ndx].wrappedValue.toggle()
                } label: {
                    Text(initials[ndx])
                        .font(Theme.value)
                        .foregroundStyle(days[ndx].wrappedValue ? Theme.onAccent : Theme.text1)
                        .frame(width: 40, height: 40)
                        .background(days[ndx].wrappedValue ? Theme.accent : Theme.sunken, in: Circle())
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(names[ndx])
                .accessibilityAddTraits(days[ndx].wrappedValue ? .isSelected : [])
            }
        }
    }
}

// The Schedule form section shared by the habit and event forms: start date, then either a
// repeat interval or day-of-week chips
struct ScheduleSection: View {

    @Binding var startDate: Date
    @Binding var useDow: Bool
    @Binding var interval: Int16
    // Sunday ... Saturday
    let days: [Binding<Bool>]

    var body: some View {
        Section {
            DatePicker("Starts", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(.compact)

            Picker("Repeats", selection: $useDow) {
                Text("Every N days").tag(false)
                Text("Days of week").tag(true)
            }
            .pickerStyle(.segmented)

            if useDow {
                DayOfWeekChips(days: days)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            } else {
                LabeledContent("Interval") {
                    TextField("1", value: $interval, format: .number)
                        .multilineTextAlignment(.trailing)
                }
            }
        } header: {
            SectionLabel("Schedule")
        } footer: {
            if useDow == false {
                Text("1 = daily, 7 = weekly")
            }
        }
        .listRowBackground(Theme.surface)
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// SCHEDULE SUMMARIES
// ---------------------------------------------------------------------------------------------------------------------

// `short` gives list-row initials ("M W F"); otherwise abbreviated names for detail cards
func scheduleSummary(useDow: Bool, repeatValue: Int, dow: dow, short: Bool) -> String {
    if useDow {
        let flags = [dow.onSun, dow.onMon, dow.onTues, dow.onWed, dow.onThurs, dow.onFri, dow.onSat]
        let labels = short ? ["S", "M", "T", "W", "T", "F", "S"] : ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let chosen = zip(flags, labels).filter { $0.0 }.map { $0.1 }
        return chosen.isEmpty ? "No days chosen" : chosen.joined(separator: short ? " " : ", ")
    }
    return repeatValue == 1 ? "Every day" : "Every \(repeatValue) days"
}
