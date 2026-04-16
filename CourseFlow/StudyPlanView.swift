import SwiftUI

struct StudyPlanView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Your study plan will appear here.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Study Plan")
        }
    }
}

#Preview {
    StudyPlanView()
}
