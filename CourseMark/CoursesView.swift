import SwiftUI

struct CoursesView: View {
    @Binding var courses: [Course]
    let assignments: [Assignment]

    @State private var showingAddCourse = false
    @State private var selectedCourseID: UUID?
    @State private var courseToDelete: Course?

    var body: some View {
        NavigationStack {
            Group {
                if courses.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)

                        Text("No courses added yet.")
                            .foregroundStyle(.secondary)

                        Button("Add Your First Course") {
                            showingAddCourse = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach($courses) { $course in
                            Button {
                                selectedCourseID = course.id
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(colorForCourse(course.colorName))
                                        .frame(width: 12, height: 12)
                                        .padding(.top, 6)

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(course.name)
                                            .font(.headline)

                                        Text(course.instructor.isEmpty ? "No instructor" : course.instructor)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }

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
                        .onDelete(perform: requestDeleteCourse)
                    }
                }
            }
            .navigationTitle("Courses")
            .toolbar {
                Button {
                    showingAddCourse = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView(courses: $courses)
            }
            .sheet(
                isPresented: Binding(
                    get: { selectedCourseID != nil },
                    set: { if !$0 { selectedCourseID = nil } }
                )
            ) {
                if let selectedCourseID,
                   let index = courses.firstIndex(where: { $0.id == selectedCourseID }) {
                    EditCourseView(course: $courses[index])
                }
            }
            .alert("Delete Course?", isPresented: Binding(
                get: { courseToDelete != nil },
                set: { if !$0 { courseToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    courseToDelete = nil
                }

                Button("Delete", role: .destructive) {
                    confirmDeleteCourse()
                }
            } message: {
                if let courseToDelete {
                    if assignments.contains(where: { $0.courseName == courseToDelete.name }) {
                        Text("This course has assignments connected to it. Deleting it may disconnect those assignments and make them appear without a matching course color.")
                    } else {
                        Text("Are you sure you want to delete this course?")
                    }
                }
            }
        }
    }

    func requestDeleteCourse(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        courseToDelete = courses[index]
    }

    func confirmDeleteCourse() {
        guard let courseToDelete else { return }

        courses.removeAll { $0.id == courseToDelete.id }

        if selectedCourseID == courseToDelete.id {
            selectedCourseID = nil
        }

        self.courseToDelete = nil
    }

    func colorForCourse(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }
}

#Preview {
    CoursesView(courses: .constant([]), assignments: [])
}
