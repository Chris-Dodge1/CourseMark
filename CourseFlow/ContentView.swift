import SwiftUI
import Foundation

struct ContentView: View {
    @State private var courses: [Course] = []
    @State private var assignments: [Assignment] = []

    private let coursesKey = "savedCourses"
    private let assignmentsKey = "savedAssignments"

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
        .onAppear {
            loadCourses()
            loadAssignments()
        }
        .onChange(of: courses) {
            saveCourses()
        }
        .onChange(of: assignments) {
            saveAssignments()
        }
    }

    func saveCourses() {
        do {
            let data = try JSONEncoder().encode(courses)
            UserDefaults.standard.set(data, forKey: coursesKey)
        } catch {
            print("Failed to save courses: \(error)")
        }
    }

    func loadCourses() {
        guard let data = UserDefaults.standard.data(forKey: coursesKey) else { return }

        do {
            courses = try JSONDecoder().decode([Course].self, from: data)
        } catch {
            print("Failed to load courses: \(error)")
        }
    }

    func saveAssignments() {
        do {
            let data = try JSONEncoder().encode(assignments)
            UserDefaults.standard.set(data, forKey: assignmentsKey)
        } catch {
            print("Failed to save assignments: \(error)")
        }
    }

    func loadAssignments() {
        guard let data = UserDefaults.standard.data(forKey: assignmentsKey) else { return }

        do {
            assignments = try JSONDecoder().decode([Assignment].self, from: data)
        } catch {
            print("Failed to load assignments: \(error)")
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

            let labels: [String]

            switch assignment.type {
            case "Exam":
                labels = [
                    "Review notes for",
                    "Practice problems for",
                    "Identify weak topics for",
                    "Final review for",
                    "Take"
                ]
            case "Quiz":
                labels = [
                    "Review material for",
                    "Practice for",
                    "Final review for",
                    "Take"
                ]
            case "Project":
                labels = [
                    "Plan",
                    "Build",
                    "Test",
                    "Refine",
                    "Submit"
                ]
            case "Essay":
                labels = [
                    "Research for",
                    "Outline",
                    "Draft",
                    "Revise",
                    "Submit"
                ]
            default:
                labels = [
                    "Start",
                    "Work on",
                    "Continue",
                    "Review",
                    "Complete"
                ]
            }

            let taskCount: Int
            if daysUntilDue <= 1 {
                taskCount = min(1, labels.count)
            } else if daysUntilDue <= 3 {
                taskCount = min(2, labels.count)
            } else if daysUntilDue <= 7 {
                taskCount = min(3, labels.count)
            } else if daysUntilDue <= 14 {
                taskCount = min(4, labels.count)
            } else {
                taskCount = min(5, labels.count)
            }

            for i in 0..<taskCount {
                let offset: Int

                if taskCount == 1 {
                    offset = 0
                } else {
                    let progress = Double(i) / Double(taskCount - 1)
                    offset = Int(progress * Double(daysUntilDue))
                }

                let taskDate = calendar.date(byAdding: .day, value: offset, to: today) ?? today
                let label = labels[i]

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
