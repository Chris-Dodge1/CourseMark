
import SwiftUI

struct AddCourseView: View {
    @Binding var courses: [Course]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var instructor = ""
    @State private var colorName = "Blue"
    
    let colors = ["Blue", "Green", "Purple", "Orange", "Red"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Course Info") {
                    TextField("Course name", text: $name)
                    TextField("Instructor (optional)", text: $instructor)
                    
                    Picker("Color", selection: $colorName) {
                        ForEach(colors, id: \.self) { color in
                            Text(color)
                        }
                    }
                }
            }
            .navigationTitle("Add Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newCourse = Course(
                            name: name,
                            instructor: instructor,
                            colorName: colorName
                        )
                        courses.append(newCourse)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddCourseView(courses: .constant([]))
}
