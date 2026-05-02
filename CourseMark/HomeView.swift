import SwiftUI

struct HomeView: View {
    let assignments: [Assignment]
    let studyTasks: [StudyTask]
    let toggleStudyTaskCompletion: (String) -> Void

    private let calendar = Calendar.current

    var upcomingTasks: [StudyTask] {
        Array(studyTasks.prefix(3))
    }

    var studyPlanPreview: [StudyTask] {
        Array(studyTasks.prefix(6))
    }

    var dueTodayCount: Int {
        assignments.filter {
            calendar.isDateInToday($0.dueDate) && !$0.isCompleted
        }.count
    }

    var dueThisWeekCount: Int {
        let today = calendar.startOfDay(for: Date())
        let weekFromNow = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        return assignments.filter {
            let dueDate = calendar.startOfDay(for: $0.dueDate)
            return dueDate >= today && dueDate <= weekFromNow && !$0.isCompleted
        }.count
    }

    var completedCount: Int {
        assignments.filter { $0.isCompleted }.count
    }

    var overdueCount: Int {
        let today = calendar.startOfDay(for: Date())

        return assignments.filter {
            let dueDate = calendar.startOfDay(for: $0.dueDate)
            return dueDate < today && !$0.isCompleted
        }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 6) {
                        Text("CourseMark")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Your study planner")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    dashboardStats

                    section(title: "Upcoming Tasks", tasks: upcomingTasks, emptyText: "No upcoming tasks yet.")

                    section(title: "Study Plan Preview", tasks: studyPlanPreview, emptyText: "Your study plan will appear here.")
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }

    var dashboardStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dashboard")
                .font(.title2)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                statCard(title: "Due Today", value: dueTodayCount, systemImage: "calendar.badge.exclamationmark")
                statCard(title: "This Week", value: dueThisWeekCount, systemImage: "calendar")
                statCard(title: "Completed", value: completedCount, systemImage: "checkmark.circle")
                statCard(title: "Overdue", value: overdueCount, systemImage: "exclamationmark.triangle")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func statCard(title: String, value: Int, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.blue)

            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    func section(title: String, tasks: [StudyTask], emptyText: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            if tasks.isEmpty {
                Text(emptyText)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ForEach(tasks) { task in
                    taskCard(task)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func taskCard(_ task: StudyTask) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                toggleStudyTaskCompletion(task.id)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                Text(task.courseName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(task.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView(
        assignments: [],
        studyTasks: [],
        toggleStudyTaskCompletion: { _ in }
    )
}
