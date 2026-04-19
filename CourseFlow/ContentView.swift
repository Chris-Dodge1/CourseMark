import SwiftUI

struct ContentView: View {
    @State private var courses: [Course] = []
    @State private var assignments: [Assignment] = []
    
    var generatedStudyTasks: [StudyTask] {
        generateStudyTasks(from: assignments)
    }
    
    var body: some View {
        TabView {
            HomeView(studyTasks: generatedStudyTasks)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            CoursesView(courses: $courses)
                .tabItem {
                    Label("Courses", systemImage: "book")
                }

            AssignmentsView(courses: $courses, assignments: $assignments)
                .tabItem {
                    Label("Assignments", systemImage: "checklist")
                }

            StudyPlanView(studyTasks: generatedStudyTasks)
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }
        }
    }
    
    func generateStudyTasks(from assignments: [Assignment]) -> [StudyTask] {
        var tasks: [StudyTask] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for assignment in assignments {
            let dueDate = calendar.startOfDay(for: assignment.dueDate)
            let daysUntilDue = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
            
            if daysUntilDue < 0 {
                continue
            }
            
            let taskCount: Int
            if daysUntilDue <= 1 {
                taskCount = 1
            } else if daysUntilDue <= 3 {
                taskCount = 2
            } else if daysUntilDue <= 7 {
                taskCount = 3
            } else if daysUntilDue <= 14 {
                taskCount = 4
            } else {
                taskCount = 5
            }
            
            let labels = ["Start", "Continue", "Review", "Polish", "Finish"]
            
            for i in 0..<taskCount {
                let offset: Int
                
                if taskCount == 1 {
                    offset = 0
                } else {
                    let progress = Double(i) / Double(taskCount - 1)
                    offset = Int(round(progress * Double(daysUntilDue)))
                }
                
                let taskDate = calendar.date(byAdding: .day, value: offset, to: today) ?? today
                let label = labels[min(i, labels.count - 1)]
                
                tasks.append(
                    StudyTask(
                        title: "\(label) \(assignment.title)",
                        courseName: assignment.courseName,
                        date: taskDate
                    )
                )
            }
        }
        
        return tasks.sorted { $0.date < $1.date }
    }
}

#Preview {
    ContentView()
}
