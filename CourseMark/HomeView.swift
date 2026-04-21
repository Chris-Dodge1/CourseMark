import SwiftUI

struct HomeView: View {
    let studyTasks: [StudyTask]
    
    var upcomingTasks: [StudyTask] {
        studyTasks.prefix(3).map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("CourseMark")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Your study planner")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Tasks")
                            .font(.title2)
                            .fontWeight(.semibold)

                        if upcomingTasks.isEmpty {
                            Text("No tasks yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(upcomingTasks) { task in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title)
                                        .font(.headline)
                                    
                                    Text(task.courseName)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(task.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView(studyTasks: [])
}
