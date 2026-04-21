import SwiftUI

struct AddAssignmentView: View {
    @Binding var assignments: [Assignment]
    let courses: [Course]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var selectedCourse = ""
    @State private var dueDate = Date()
    @State private var priority = "Medium"
    @State private var type = "Homework"
    @State private var notes = ""
    
    let priorities = ["Low", "Medium", "High"]
    let assignmentTypes = ["Homework", "Exam", "Quiz", "Project", "Essay"]
    
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
                            Text(assignmentType)
                        }
                    }
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { level in
                            Text(level)
                        }
                    }
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Add Assignment")
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
                        let newAssignment = Assignment(
                            title: title,
                            courseName: selectedCourse,
                            dueDate: dueDate,
                            priority: priority,
                            type: type,
                            notes: notes
                        )
                        assignments.append(newAssignment)
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
    AddAssignmentView(assignments: .constant([]), courses: [
        Course(name: "CSE 4310", instructor: "Professor", colorName: "Blue")
    ])
}
