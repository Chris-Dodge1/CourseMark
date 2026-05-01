import SwiftUI

struct AssignmentsView: View {
    @Binding var courses: [Course]
    @Binding var assignments: [Assignment]

    @State private var showingAddAssignment = false
    @State private var selectedAssignmentID: UUID?

    @State private var selectedCourseFilter: String = "All"
    @State private var selectedStatusFilter: String = "All"

    var filteredAssignments: [Assignment] {
        assignments.filter { assignment in
            let matchesCourse =
                selectedCourseFilter == "All" ||
                assignment.courseName == selectedCourseFilter

            let matchesStatus =
                selectedStatusFilter == "All" ||
                (selectedStatusFilter == "Active" && !assignment.isCompleted) ||
                (selectedStatusFilter == "Completed" && assignment.isCompleted)

            return matchesCourse && matchesStatus
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if courses.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)

                        Text("Add a course before creating assignments.")
                            .foregroundStyle(.secondary)
                    }
                } else if assignments.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checklist")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)

                        Text("No assignments added yet.")
                            .foregroundStyle(.secondary)

                        Button("Add Your First Assignment") {
                            showingAddAssignment = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack(spacing: 0) {
                        filterBar

                        if filteredAssignments.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)

                                Text("No assignments match these filters.")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List {
                                ForEach(filteredAssignments, id: \.id) { assignment in
                                    if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
                                        let binding = $assignments[index]

                                        Button {
                                            selectedAssignmentID = binding.wrappedValue.id
                                        } label: {
                                            assignmentRow(binding)
                                        }
                                        .buttonStyle(.plain)
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                binding.wrappedValue.isCompleted.toggle()
                                            } label: {
                                                Label(
                                                    binding.wrappedValue.isCompleted ? "Undo" : "Complete",
                                                    systemImage: binding.wrappedValue.isCompleted ? "arrow.uturn.backward" : "checkmark"
                                                )
                                            }
                                            .tint(binding.wrappedValue.isCompleted ? .orange : .green)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                deleteAssignment(id: binding.wrappedValue.id)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Assignments")
            .toolbar {
                if !courses.isEmpty {
                    Button {
                        showingAddAssignment = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAssignment) {
                AddAssignmentView(assignments: $assignments, courses: courses)
            }
            .sheet(
                isPresented: Binding(
                    get: { selectedAssignmentID != nil },
                    set: { if !$0 { selectedAssignmentID = nil } }
                )
            ) {
                if let selectedAssignmentID,
                   let index = assignments.firstIndex(where: { $0.id == selectedAssignmentID }) {
                    EditAssignmentView(
                        assignment: $assignments[index],
                        courses: courses
                    )
                }
            }
        }
    }

    var filterBar: some View {
        HStack(spacing: 12) {
            Picker("Course", selection: $selectedCourseFilter) {
                Text("All Courses").tag("All")

                ForEach(courses, id: \.name) { course in
                    Text(course.name).tag(course.name)
                }
            }
            .pickerStyle(.menu)

            Picker("Status", selection: $selectedStatusFilter) {
                Text("All").tag("All")
                Text("Active").tag("Active")
                Text("Completed").tag("Completed")
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    func assignmentRow(_ assignment: Binding<Assignment>) -> some View {
        let a = assignment.wrappedValue

        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: a.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(a.isCompleted ? .green : .secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text(a.title)
                    .font(.headline)
                    .strikethrough(a.isCompleted)
                    .foregroundStyle(a.isCompleted ? .secondary : .primary)

                Text(a.courseName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Type: \(a.type)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Priority: \(a.priority)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Due: \(a.dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 6)
        }
        .contentShape(Rectangle())
    }

    func deleteAssignments(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredAssignments[$0].id }
        assignments.removeAll { idsToDelete.contains($0.id) }
    }

    func deleteAssignment(id: UUID) {
        assignments.removeAll { $0.id == id }
    }
}

#Preview {
    AssignmentsView(courses: .constant([]), assignments: .constant([]))
}
