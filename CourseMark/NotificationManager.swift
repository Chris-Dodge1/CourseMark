import Foundation
import UserNotifications

struct NotificationManager {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                print("Notification permission error: \(error)")
            }

            print("Notification permission granted: \(granted)")
        }
    }

    static func scheduleAssignmentReminders(
        for assignments: [Assignment],
        remindersEnabled: Bool,
        reminderTime: Date
    ) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: assignments.map { "assignment-\($0.id.uuidString)" }
        )

        guard remindersEnabled else { return }

        for assignment in assignments where !assignment.isCompleted {
            scheduleReminder(for: assignment, reminderTime: reminderTime)
        }
    }

    private static func scheduleReminder(for assignment: Assignment, reminderTime: Date) {
        let calendar = Calendar.current

        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)

        guard let hour = timeComponents.hour,
              let minute = timeComponents.minute,
              let reminderDate = calendar.date(
                bySettingHour: hour,
                minute: minute,
                second: 0,
                of: assignment.dueDate
              ) else {
            return
        }

        guard reminderDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Assignment Due Today"
        content.body = "\(assignment.title) is due today for \(assignment.courseName)."
        content.sound = .default

        let dateComponents = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "assignment-\(assignment.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule reminder: \(error)")
            }
        }
    }
}
