import SwiftUI

struct DashboardDetailView: View {
    let title: String
    let assignments: [Assignment]

    var body: some View {
        List {
            if assignments.isEmpty {
                Text("No assignments in this category.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(assignments) { assignment in
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

                            Text(assignment.priority)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(priorityColor(assignment.priority).opacity(0.15))
                                .foregroundStyle(priorityColor(assignment.priority))
                                .clipShape(Capsule())
                        }

                        Text("Due: \(assignment.dueDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(title)
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
    DashboardDetailView(title: "Due Today", assignments: [])
}
