//
//  DateBarView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import SwiftData

// Graphical date picker, presented as a sheet from the date bar
struct CustomDatePicker: View {
    @Binding var SelectedDate: Date
    @Binding var showingPicker: Bool

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("", selection: $SelectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal, 16)

                Spacer(minLength: 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingPicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(Theme.surface)
    }
}

// The Today screen's header block: date, day score, and the Double Rule
struct DateBarView: View {

    @Binding var SelectedDate: Date

    // All stored daily scores; we pick out the one matching SelectedDate so chevroning
    // through the calendar shows that day's point total. Today's record updates live as
    // habits are completed, so this re-renders automatically.
    @Query
    private var dayScores: [dayScore]

    // The selected day's checklist, which the goal is derived from. Querying it (rather than
    // reading a stored number) is what makes the goal climb the moment a task or habit lands
    // on the docket.
    @Query
    private var dayItems: [listItem]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showingPicker = false

    // What is drawn, as opposed to what is true: these trail `isClosed` so the day-complete
    // celebration can animate them in, while every other change (launch, switching days) is instant.
    @State private var ruleClosed = false
    @State private var labelClosed = false
    @State private var scoreFlash = false

    init(SelectedDate: Binding<Date>) {
        _SelectedDate = SelectedDate

        let dayStart = calendar.startOfDay(for: SelectedDate.wrappedValue)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

        _dayItems = Query(filter: #Predicate<listItem> { item in
            item.timestamp >= dayStart && item.timestamp < dayEnd
        }, sort: \listItem.timestamp)
    }

    private var displayedScore: Int {
        dayScores.first(where: {
            calendar.isDate($0.day, inSameDayAs: SelectedDate)
        })?.score ?? 0
    }

    private var displayedGoal: Int {
        goalTotal(for: dayItems)
    }

    private var isToday: Bool { calendar.isDateInToday(SelectedDate) }

    private var isClosed: Bool { displayedGoal > 0 && displayedScore >= displayedGoal }

    private struct DayState: Equatable {
        let day: Date
        let closed: Bool
    }

    private var dayState: DayState {
        DayState(day: calendar.startOfDay(for: SelectedDate), closed: isClosed)
    }

    // View-only celebration; celebrationProcedure() and its latch in Globals are separate
    private func celebrate() {
        withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .easeOut(duration: 0.6).delay(0.15)) {
            ruleClosed = true
        }
        withAnimation(.easeIn(duration: 0.2)) {
            labelClosed = true
        }
        scoreFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            scoreFlash = false
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private var scoreText: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("\(displayedScore)")
                .font(Theme.bigValue)
                .foregroundStyle(scoreFlash ? Theme.accent : Theme.text1)
            Text("/\(displayedGoal) pts")
                .font(Theme.value)
                .foregroundStyle(Theme.text2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(displayedScore) of \(displayedGoal) points")
    }

    private var closedLabel: some View {
        SectionLabel("Day closed", color: Theme.accent)
            .transition(.opacity)
    }

    private var todayChip: some View {
        Button {
            SelectedDate = Date()
        } label: {
            Text("Today")
                .font(Theme.value)
                .foregroundStyle(Theme.text1)
                .padding(.horizontal, 12)
                .frame(minHeight: 32)
                .background(Theme.sunken, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(FadeButtonStyle())
        .accessibilityLabel("Go to today")
    }

    @ViewBuilder
    private var scoreTrailing: some View {
        if isToday == false {
            todayChip
        } else if labelClosed {
            closedLabel
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack(alignment: .center, spacing: 0) {

                Button {
                    showingPicker = true
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(SelectedDate, format: .dateTime.weekday(.wide))
                            .font(Theme.screenTitle)
                            .foregroundStyle(Theme.text1)
                        HStack(spacing: 6) {
                            Text(SelectedDate, format: .dateTime.day().month(.wide).year())
                                .font(Theme.meta)
                                .foregroundStyle(Theme.text2)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.text3)
                        }
                    }
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(FadeButtonStyle())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Choose date")
                .accessibilityValue(Text(SelectedDate, format: .dateTime.weekday(.wide).day().month(.wide).year()))
                .accessibilityAddTraits(.isButton)

                Spacer(minLength: 8)

                IconButton(systemName: "chevron.left", label: "Previous day") {
                    SelectedDate = calendar.date(byAdding: .day, value: -1, to: SelectedDate)!
                }

                IconButton(systemName: "chevron.right", label: "Next day") {
                    SelectedDate = calendar.date(byAdding: .day, value: 1, to: SelectedDate)!
                }
            }

            // Wraps the trailing slot under the score when the two don't fit side by side
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 8) {
                    scoreText
                    Spacer(minLength: 8)
                    scoreTrailing
                }
                VStack(alignment: .leading, spacing: 4) {
                    scoreText
                    scoreTrailing
                }
            }
            .frame(minHeight: 44)
            .padding(.top, 12)

            if isToday == false && labelClosed {
                closedLabel
            }

            DoubleRule(fraction: displayedGoal > 0 ? Double(displayedScore) / Double(displayedGoal) : 0,
                       closed: ruleClosed)
                .id(dayState.day) // a different day is a different rule: no width animation between days
                .padding(.top, 8)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Day progress, \(displayedScore) of \(displayedGoal) points" + (isClosed ? ", day closed" : ""))
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .sheet(isPresented: $showingPicker) {
            CustomDatePicker(SelectedDate: $SelectedDate, showingPicker: $showingPicker)
        }
        .onAppear {
            ruleClosed = isClosed
            labelClosed = isClosed
        }
        .onChange(of: dayState) { old, new in
            if old.day == new.day && old.closed == false && new.closed == true && isToday {
                celebrate()
            } else {
                ruleClosed = new.closed
                labelClosed = new.closed
            }
        }
    }
}
