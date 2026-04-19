import SwiftUI

struct StudyPlanView: View {
    let studyTasks: [StudyTask]
    
    var body: some View {
        NavigationStack {
            Group {
                if studyTasks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        
                        Text("Your study plan will appear here.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List(studyTasks) { task in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(task.title)
                                .font(.headline)
                            
                            Text(task.courseName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(task.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Study Plan")
        }
    }
}

#Preview {
    StudyPlanView(studyTasks: [])
}
