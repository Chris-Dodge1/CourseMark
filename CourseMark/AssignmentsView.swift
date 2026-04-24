import SwiftUI

struct AssignmentsView: View {
    @Binding var courses: [Course]
    @Binding var assignments: [Assignment]

    @State private var showingAddAssignment = false
    @State private var selectedAssignmentID: UUID?

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
                    List {
                        ForEach($assignments) { $assignment in
                            Button {
                                selectedAssignmentID = assignment.id
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Button {
                                        assignment.isCompleted.toggle()
                                    } label: {
                                        Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                    }
                                    .buttonStyle(.plain)

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(assignment.title)
                                            .font(.headline)
                                            .strikethrough(assignment.isCompleted)
                                            .foregroundStyle(assignment.isCompleted ? .secondary : .primary)

                                        Text(assignment.courseName)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        Text("Type: \(assignment.type)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        Text("Priority: \(assignment.priority)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        Text("Due: \(assignment.dueDate.formatted(date: .abbreviated, time: .omitted))")
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
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: deleteAssignments)
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

    func deleteAssignments(at offsets: IndexSet) {
        assignments.remove(atOffsets: offsets)
    }
}

#Preview {
    AssignmentsView(courses: .constant([]), assignments: .constant([]))
}
