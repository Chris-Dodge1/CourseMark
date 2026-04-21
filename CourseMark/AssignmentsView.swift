import SwiftUI

struct AssignmentsView: View {
    @Binding var courses: [Course]
    @Binding var assignments: [Assignment]

    @State private var showingAddAssignment = false

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
                        ForEach(assignments) { assignment in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(assignment.title)
                                    .font(.headline)

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
        }
    }

    func deleteAssignments(at offsets: IndexSet) {
        assignments.remove(atOffsets: offsets)
    }
}

#Preview {
    AssignmentsView(courses: .constant([]), assignments: .constant([]))
}
