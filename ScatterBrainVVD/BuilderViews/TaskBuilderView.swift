//
//  TaskBuilderView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 6/28/25.
//

import SwiftUI
import SwiftData

struct TaskBuilderView: View {

    @Query(sort: \taskItem.name, animation: .default)
    private var taskData: [taskItem]

    @Environment(\.modelContext) private var modelContext
    
    @State var DisplayTaskMaker: Bool = false
    @State var DisplayTaskEditor: Bool = false
    
    @State var TaskNameSet: String = "Task"
    @State var TaskDescriptionSet: String = ""
    @State var TaskRewardSet: Int16 = 1
    @State var TaskDueDateSet: Date = Date()
    @State var TaskUnitSet: String = "units"
    @State var TaskGoalSet: Int16 = 1
    @State var TaskHasCheckboxSet: Bool = true
    @State var TaskIsntFloatingSet: Bool = true
    
    
    // Pushed task detail pages; emptied to pop back to the list once the task is gone
    @State private var path: [taskItem] = []
    @State private var confirmRemove: Bool = false

    private var taskBuilderForm: some View {

        Form {

            Section {
                TextField("Task name", text: $TaskNameSet)
            } header: {
                SectionLabel("Name")
            }
            .listRowBackground(Theme.surface)

            Section {
                Picker("Tracking", selection: $TaskHasCheckboxSet) {
                    Text("Checkbox").tag(true)
                    Text("Count").tag(false)
                }
                .pickerStyle(.segmented)

                if TaskHasCheckboxSet == false {
                    LabeledContent("Goal") {
                        TextField("1", value: $TaskGoalSet, format: .number)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Unit") {
                        TextField("units", text: $TaskUnitSet)
                            .multilineTextAlignment(.trailing)
                    }
                }
            } header: {
                SectionLabel("Tracking")
            }
            .listRowBackground(Theme.surface)

            Section {
                DatePicker("Date",
                           selection: $TaskDueDateSet,
                           displayedComponents: .date)
                .datePickerStyle(.compact)

                Toggle("Carry over until done", isOn: Binding(
                    get: { !TaskIsntFloatingSet },
                    set: { TaskIsntFloatingSet = !$0 }))
            } header: {
                SectionLabel("Date")
            } footer: {
                Text("Stays on Today until you finish it")
            }
            .listRowBackground(Theme.surface)

            Section {
                NotesEditor(text: $TaskDescriptionSet)
            } header: {
                SectionLabel("Notes")
            }
            .listRowBackground(Theme.surface)

            Section {
                LabeledContent("Reward") {
                    TextField("1", value: $TaskRewardSet, format: .number)
                        .multilineTextAlignment(.trailing)
                }
            } footer: {
                Text("Points for completing")
            }
            .listRowBackground(Theme.surface)
        }
        .daybookForm()
    }

    // One form for both create and edit; only the title and the Save action differ
    private func taskFormSheet(title: String, onCancel: @escaping () -> Void, onSave: @escaping () -> Void) -> some View {
        NavigationStack {
            taskBuilderForm
                .formSheetToolbar(title: title, onCancel: onCancel, onSave: onSave)
        }
    }

    // The form fields are shared state, so a new task starts from the defaults rather than
    // from whatever was last edited
    private func resetForm() {
        TaskNameSet = "Task"
        TaskDescriptionSet = ""
        TaskRewardSet = 1
        TaskDueDateSet = Date()
        TaskUnitSet = "units"
        TaskGoalSet = 1
        TaskHasCheckboxSet = true
        TaskIsntFloatingSet = true
    }

    private func taskDetail(_ taskNdx: taskItem) -> some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text(taskNdx.name)
                    .font(Theme.detailTitle)
                    .foregroundStyle(Theme.text1)
                    .accessibilityAddTraits(.isHeader)

                RowCard {
                    if taskNdx.hasCheckbox == false {
                        CardRow(label: "Goal", value: "\(taskNdx.goal) \(taskNdx.unit)")
                    }
                    CardRow(label: "Due", value: taskNdx.dueDate.formatted(date: .abbreviated, time: .omitted))
                }

                if taskNdx.descript != "" {
                    TextCard(text: taskNdx.descript)
                }

                VStack(spacing: 12) {
                    Button("Move to today's list") {
                        path.removeAll()
                        shuntTask(taskToShunt: taskNdx, modelContext: modelContext)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Edit task") {
                        TaskNameSet = taskNdx.name
                        TaskDescriptionSet = taskNdx.descript
                        TaskRewardSet = Int16(taskNdx.reward)
                        TaskDueDateSet = taskNdx.dueDate
                        TaskUnitSet = taskNdx.unit
                        TaskGoalSet = Int16(taskNdx.goal)
                        TaskHasCheckboxSet = taskNdx.hasCheckbox
                        TaskIsntFloatingSet = taskNdx.notFloater

                        DisplayTaskEditor = true
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Remove task") {
                        confirmRemove = true
                    }
                    .buttonStyle(SecondaryButtonStyle(destructive: true))
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $DisplayTaskEditor) {
            taskFormSheet(title: "Edit task", onCancel: { DisplayTaskEditor = false }) {
                DisplayTaskEditor = false
                updateTask(taskToEdit: taskNdx)
            }
        }
    }

    var body: some View {

        NavigationStack(path: $path) {

            VStack(spacing: 0) {

                ScreenHeader(title: "Tasks") {
                    IconButton(systemName: "plus", label: "New task") {
                        resetForm()
                        DisplayTaskMaker = true
                    }
                }

                if taskData.isEmpty == false {

                    List{
                        ForEach(taskData) { taskNdx in

                            NavigationLink(value: taskNdx) {
                                HStack(spacing: 12) {
                                    CheckControl(isTask: true, complete: false, size: 20)
                                        .accessibilityHidden(true)

                                    Text(taskNdx.name)
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.text1)
                                        .lineLimit(3)

                                    Spacer(minLength: 0)

                                    Text(taskNdx.dueDate, format: .dateTime.day().month(.abbreviated))
                                        .font(Theme.value)
                                        .foregroundStyle(Theme.text2)
                                }
                                .frame(minHeight: 44)
                            }
                            .listRowBackground(Theme.surface)
                            .listRowSeparatorTint(Theme.separator)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                } // END IF STATEMENT
                else {
                    EmptyState(symbol: "checkmark.square",
                               title: "No tasks waiting",
                               sentence: "Tasks wait here until their date, then move to Today.",
                               buttonTitle: "New task") {
                        resetForm()
                        DisplayTaskMaker = true
                    }
                }

            } // End Vstack
            .background(Theme.bg)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: taskItem.self) { taskNdx in
                taskDetail(taskNdx)
            }
        }
        // Presented from the stack rather than the detail page: the page is popped by the
        // Remove action, and a dialog whose presenter disappears mid-dismissal eats the next tap.
        .confirmationDialog("Remove this task?", isPresented: $confirmRemove, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                if let taskNdx = path.last {
                    path.removeAll()
                    deleteEntityTask(withUUID: taskNdx.id, modelContext: modelContext)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $DisplayTaskMaker) {
            taskFormSheet(title: "New task", onCancel: { DisplayTaskMaker = false }) {
                addTask()
            }
        }
    }
    /*    ------------------------------------------------
                  ADD TASK
     ------------------------------------------------     */
    
    private func updateTask(taskToEdit: taskItem) {

        taskToEdit.name = TaskNameSet
        taskToEdit.goal = Int(TaskGoalSet)
        taskToEdit.unit = TaskUnitSet
        taskToEdit.descript = TaskDescriptionSet
        taskToEdit.dueDate = TaskDueDateSet
        taskToEdit.reward = Int(TaskRewardSet)
        taskToEdit.hasCheckbox = TaskHasCheckboxSet

        if taskToEdit.hasCheckbox == true {
            taskToEdit.goal = 1
            taskToEdit.unit = "units"
        }

        saveContext(modelContext: modelContext)
    }

    private func addTask() {

        if TaskHasCheckboxSet == true {
            TaskGoalSet = 1
        }

        let newTaskItem = taskItem(descript: TaskDescriptionSet,
                                   dueDate: TaskDueDateSet,
                                   goal: Int(TaskGoalSet),
                                   hasCheckbox: TaskHasCheckboxSet,
                                   id: UUID(),
                                   name: TaskNameSet,
                                   notFloater: TaskIsntFloatingSet,
                                   reward: Int(TaskRewardSet),
                                   unit: TaskUnitSet)

        modelContext.insert(newTaskItem)
        saveContext(modelContext: modelContext)


        DisplayTaskMaker = false
        TaskNameSet = "Task"
        TaskDescriptionSet = ""
        TaskRewardSet = 1
        TaskDueDateSet = Date()
        TaskUnitSet = "units"
        TaskGoalSet = 1
        TaskHasCheckboxSet = true
        TaskIsntFloatingSet = true
        
        shuntTodaysTasks(modelContext: modelContext)

    }


}

//#Preview {
//    TaskBuilderView()
//}
