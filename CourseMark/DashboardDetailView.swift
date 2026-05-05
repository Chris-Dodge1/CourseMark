import SwiftUI

struct DashboardDetailView: View {
    let title: String
    @Binding var assignments: [Assignment]
    let assignmentIDs: [UUID]
    let courses: [Course]

    @State private var selectedAssignmentID: UUID?

    var displayedAssignments: [Assignment] {
        assignments.filter { assignmentIDs.contains($0.id) }
    }

    var body: some View {
        List {
            if displayedAssignments.isEmpty {
                Text("No assignments in this category.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(displayedAssignments) { assignment in
                    Button {
                        selectedAssignmentID = assignment.id
                    } label: {
                        assignmentRow(assignment)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle(title)
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

    func assignmentRow(_ assignment: Assignment) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(assignment.title)
                .font(.headline)
                .strikethrough(assignment.isCompleted)

            Text(assignment.courseName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text(assignment.type)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                priorityBadge(assignment.priority)
            }

            Text("Due: \(assignment.dueDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    func priorityBadge(_ priority: String) -> some View {
        Text(priority)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priorityColor(priority).opacity(0.15))
            .foregroundStyle(priorityColor(priority))
            .clipShape(Capsule())
    }

    func priorityColor(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .green
        default: return .gray
        }
    }
}

#Preview {
    DashboardDetailView(
        title: "Due Today",
        assignments: .constant([]),
        assignmentIDs: [],
        courses: []
    )
}
