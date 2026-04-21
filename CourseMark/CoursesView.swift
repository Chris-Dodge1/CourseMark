import SwiftUI

struct CoursesView: View {
    @Binding var courses: [Course]
    @State private var showingAddCourse = false

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
                        ForEach(courses) { course in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(course.name)
                                    .font(.headline)

                                Text(course.instructor)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text("Color: \(course.colorName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteCourses)
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
        }
    }

    func deleteCourses(at offsets: IndexSet) {
        courses.remove(atOffsets: offsets)
    }
}

#Preview {
    CoursesView(courses: .constant([]))
}
