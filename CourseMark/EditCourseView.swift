import SwiftUI

struct EditCourseView: View {
    @Binding var course: Course

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var instructor: String
    @State private var colorName: String

    let colors = ["Blue", "Green", "Purple", "Orange", "Red"]

    init(course: Binding<Course>) {
        self._course = course

        _name = State(initialValue: course.wrappedValue.name)
        _instructor = State(initialValue: course.wrappedValue.instructor)
        _colorName = State(initialValue: course.wrappedValue.colorName)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Course Info") {
                    TextField("Course name", text: $name)
                    TextField("Instructor (optional)", text: $instructor)

                    Picker("Color", selection: $colorName) {
                        ForEach(colors, id: \.self) { color in
                            Text(color).tag(color)
                        }
                    }
                }
            }
            .navigationTitle("Edit Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        course.name = name
                        course.instructor = instructor
                        course.colorName = colorName
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditCourseView(
        course: .constant(
            Course(name: "CSE 4310", instructor: "Professor", colorName: "Blue")
        )
    )
}
