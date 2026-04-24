import SwiftUI

struct EditAssignmentView: View {
    @Binding var assignment: Assignment
    let courses: [Course]

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var selectedCourse: String
    @State private var dueDate: Date
    @State private var priority: String
    @State private var type: String
    @State private var notes: String
    @State private var isCompleted: Bool

    let priorities = ["Low", "Medium", "High"]
    let assignmentTypes = ["Homework", "Exam", "Quiz", "Project", "Essay"]

    init(assignment: Binding<Assignment>, courses: [Course]) {
        self._assignment = assignment
        self.courses = courses

        _title = State(initialValue: assignment.wrappedValue.title)
        _selectedCourse = State(initialValue: assignment.wrappedValue.courseName)
        _dueDate = State(initialValue: assignment.wrappedValue.dueDate)
        _priority = State(initialValue: assignment.wrappedValue.priority)
        _type = State(initialValue: assignment.wrappedValue.type)
        _notes = State(initialValue: assignment.wrappedValue.notes)
        _isCompleted = State(initialValue: assignment.wrappedValue.isCompleted)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Assignment Info") {
                    TextField("Title", text: $title)

                    Picker("Course", selection: $selectedCourse) {
                        ForEach(courses, id: \.name) { course in
                            Text(course.name).tag(course.name)
                        }
                    }

                    Picker("Type", selection: $type) {
                        ForEach(assignmentTypes, id: \.self) { assignmentType in
                            Text(assignmentType).tag(assignmentType)
                        }
                    }

                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)

                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }

                    Toggle("Completed", isOn: $isCompleted)

                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Edit Assignment")
            .onAppear {
                if selectedCourse.isEmpty, let firstCourse = courses.first {
                    selectedCourse = firstCourse.name
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        assignment.title = title
                        assignment.courseName = selectedCourse
                        assignment.dueDate = dueDate
                        assignment.priority = priority
                        assignment.type = type
                        assignment.notes = notes
                        assignment.isCompleted = isCompleted
                        dismiss()
                    }
                    .disabled(
                        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        selectedCourse.isEmpty
                    )
                }
            }
        }
    }
}

#Preview {
    EditAssignmentView(
        assignment: .constant(
            Assignment(
                title: "Homework 3",
                courseName: "CSE 4310",
                dueDate: Date(),
                priority: "Medium",
                type: "Homework",
                notes: "Finish questions 1-5",
                isCompleted: false
            )
        ),
        courses: [
            Course(name: "CSE 4310", instructor: "Professor", colorName: "Blue")
        ]
    )
}
