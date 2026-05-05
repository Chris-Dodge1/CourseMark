import SwiftUI
import Foundation
import UserNotifications

struct ContentView: View {
    @State private var courses: [Course] = []
    @State private var assignments: [Assignment] = []
    @State private var completedStudyTaskIDs: Set<String> = []

    @State private var remindersEnabled: Bool = true
    @State private var reminderTime: Date = Calendar.current.date(
        bySettingHour: 9,
        minute: 0,
        second: 0,
        of: Date()
    ) ?? Date()
    @State private var reminderOffsetDays: Int = 0

    private let coursesKey = "savedCourses"
    private let assignmentsKey = "savedAssignments"
    private let completedStudyTaskIDsKey = "completedStudyTaskIDs"
    private let remindersEnabledKey = "remindersEnabled"
    private let reminderTimeKey = "reminderTime"
    private let reminderOffsetDaysKey = "reminderOffsetDays"

    var generatedStudyTasks: [StudyTask] {
        generateStudyTasks(from: assignments)
    }

    var body: some View {
        TabView {
            HomeView(
                assignments: $assignments,
                courses: courses,
                studyTasks: generatedStudyTasks,
                toggleStudyTaskCompletion: toggleStudyTaskCompletion
            )
            .tabItem {
                Label("Home", systemImage: "house")
            }

            CoursesView(
                courses: $courses,
                assignments: assignments
            )
            .tabItem {
                Label("Courses", systemImage: "book")
            }

            AssignmentsView(
                courses: $courses,
                assignments: $assignments
            )
            .tabItem {
                Label("Assignments", systemImage: "checklist")
            }

            CalendarView(
                courses: courses,
                assignments: $assignments,
                studyTasks: generatedStudyTasks,
                toggleStudyTaskCompletion: toggleStudyTaskCompletion
            )
            .tabItem {
                Label("Calendar", systemImage: "calendar.badge.clock")
            }

            SettingsView(
                remindersEnabled: $remindersEnabled,
                reminderTime: $reminderTime,
                reminderOffsetDays: $reminderOffsetDays
            )
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .onAppear {
            loadCourses()
            loadAssignments()
            loadCompletedStudyTaskIDs()
            loadReminderSettings()

            NotificationManager.requestPermission()
            scheduleReminders()
        }
        .onChange(of: courses) {
            saveCourses()
        }
        .onChange(of: assignments) {
            saveAssignments()
            scheduleReminders()
        }
        .onChange(of: completedStudyTaskIDs) {
            saveCompletedStudyTaskIDs()
        }
        .onChange(of: remindersEnabled) {
            saveReminderSettings()
            scheduleReminders()
        }
        .onChange(of: reminderTime) {
            saveReminderSettings()
            scheduleReminders()
        }
        .onChange(of: reminderOffsetDays) {
            saveReminderSettings()
            scheduleReminders()
        }
    }

    func scheduleReminders() {
        NotificationManager.scheduleAssignmentReminders(
            for: assignments,
            remindersEnabled: remindersEnabled,
            reminderTime: reminderTime,
            reminderOffsetDays: reminderOffsetDays
        )
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

    func saveCompletedStudyTaskIDs() {
        let idsArray = Array(completedStudyTaskIDs)
        UserDefaults.standard.set(idsArray, forKey: completedStudyTaskIDsKey)
    }

    func loadCompletedStudyTaskIDs() {
        let idsArray = UserDefaults.standard.stringArray(forKey: completedStudyTaskIDsKey) ?? []
        completedStudyTaskIDs = Set(idsArray)
    }

    func saveReminderSettings() {
        UserDefaults.standard.set(remindersEnabled, forKey: remindersEnabledKey)
        UserDefaults.standard.set(reminderTime, forKey: reminderTimeKey)
        UserDefaults.standard.set(reminderOffsetDays, forKey: reminderOffsetDaysKey)
    }

    func loadReminderSettings() {
        remindersEnabled = UserDefaults.standard.object(forKey: remindersEnabledKey) as? Bool ?? true

        if let savedTime = UserDefaults.standard.object(forKey: reminderTimeKey) as? Date {
            reminderTime = savedTime
        }

        reminderOffsetDays = UserDefaults.standard.object(forKey: reminderOffsetDaysKey) as? Int ?? 0
    }

    func toggleStudyTaskCompletion(for taskID: String) {
        if completedStudyTaskIDs.contains(taskID) {
            completedStudyTaskIDs.remove(taskID)
        } else {
            completedStudyTaskIDs.insert(taskID)
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
                labels = ["Review notes for", "Practice problems for", "Identify weak topics for", "Final review for", "Take"]
            case "Quiz":
                labels = ["Review material for", "Practice for", "Final review for", "Take"]
            case "Project":
                labels = ["Plan", "Build", "Test", "Refine", "Submit"]
            case "Essay":
                labels = ["Research for", "Outline", "Draft", "Revise", "Submit"]
            default:
                labels = ["Start", "Work on", "Continue", "Review", "Complete"]
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
                let title = "\(label) \(assignment.title)"

                let dateString = ISO8601DateFormatter().string(from: taskDate)
                let taskID = "\(assignment.id.uuidString)-\(i)-\(dateString)"

                tasks.append(
                    StudyTask(
                        id: taskID,
                        title: title,
                        courseName: assignment.courseName,
                        date: taskDate,
                        isCompleted: completedStudyTaskIDs.contains(taskID)
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
