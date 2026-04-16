import SwiftUI

struct AssignmentsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("No assignments added yet.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Assignments")
        }
    }
}

#Preview {
    AssignmentsView()
}
