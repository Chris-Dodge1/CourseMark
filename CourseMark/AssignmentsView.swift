import SwiftUI

struct AssignmentsView: View {
    @Binding var courses: [Course]
    @Binding var assignments: [Assignment]

    @State private var showingAddAssignment = false
    @State private var selectedAssignmentID: UUID?

    @State private var selectedCourseFilter: String = "All"
    @State private var selectedStatusFilter: String = "All"
    @State private var selectedSortOption: String = "Due Date"
    @State private var searchText: String = ""

    let sortOptions = ["Due Date", "Priority", "Course", "Status"]

    var filteredAssignments: [Assignment] {
        let filtered = assignments.filter { assignment in
            let matchesCourse =
                selectedCourseFilter == "All" ||
                assignment.courseName == selectedCourseFilter

            let matchesStatus =
                selectedStatusFilter == "All" ||
                (selectedStatusFilter == "Active" && !assignment.isCompleted) ||
                (selectedStatusFilter == "Completed" && assignment.isCompleted)

            let matchesSearch =
                searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                assignment.title.localizedCaseInsensitiveContains(searchText) ||
                assignment.courseName.localizedCaseInsensitiveContains(searchText) ||
                assignment.type.localizedCaseInsensitiveContains(searchText) ||
                assignment.priority.localizedCaseInsensitiveContains(searchText)

            return matchesCourse && matchesStatus && matchesSearch
        }

        switch selectedSortOption {
        case "Priority":
            return filtered.sorted {
                priorityValue($0.priority) > priorityValue($1.priority)
            }
        case "Course":
            return filtered.sorted {
                $0.courseName < $1.courseName
            }
        case "Status":
            return filtered.sorted {
                !$0.isCompleted && $1.isCompleted
            }
        default:
            return filtered.sorted {
                $0.dueDate < $1.dueDate
            }
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
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)

                                Text("No assignments match your search or filters.")
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
            .searchable(text: $searchText, prompt: "Search assignments")
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
        VStack(spacing: 8) {
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

            HStack {
                Picker("Sort", selection: $selectedSortOption) {
                    ForEach(sortOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.menu)

                Spacer()

                Text("Sorted by \(selectedSortOption)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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

                priorityBadge(a.priority)

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
        case "high":
            return .red
        case "medium":
            return .orange
        case "low":
            return .green
        default:
            return .gray
        }
    }

    func priorityValue(_ priority: String) -> Int {
        switch priority.lowercased() {
        case "high":
            return 3
        case "medium":
            return 2
        case "low":
            return 1
        default:
            return 0
        }
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
