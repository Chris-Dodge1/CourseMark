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
        
        for assignment in assignments {
            let dueDate = assignment.dueDate
            
            let firstDate = calendar.date(byAdding: .day, value: -3, to: dueDate) ?? dueDate
            let secondDate = calendar.date(byAdding: .day, value: -2, to: dueDate) ?? dueDate
            let thirdDate = calendar.date(byAdding: .day, value: -1, to: dueDate) ?? dueDate
            
            tasks.append(
                StudyTask(
                    title: "Start \(assignment.title)",
                    courseName: assignment.courseName,
                    date: firstDate
                )
            )
            
            tasks.append(
                StudyTask(
                    title: "Continue \(assignment.title)",
                    courseName: assignment.courseName,
                    date: secondDate
                )
            )
            
            tasks.append(
                StudyTask(
                    title: "Finish \(assignment.title)",
                    courseName: assignment.courseName,
                    date: thirdDate
                )
            )
        }
        
        return tasks.sorted { $0.date < $1.date }
    }
}

#Preview {
    ContentView()
}
