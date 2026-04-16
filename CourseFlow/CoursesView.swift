import SwiftUI

struct CoursesView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("No courses added yet.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Courses")
        }
    }
}

#Preview {
    CoursesView()
}
