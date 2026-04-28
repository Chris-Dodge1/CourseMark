import SwiftUI

struct SettingsView: View {
    @Binding var remindersEnabled: Bool
    @Binding var reminderTime: Date

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminders") {
                    Toggle("Enable Reminders", isOn: $remindersEnabled)

                    DatePicker(
                        "Reminder Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!remindersEnabled)
                }

                Section("About") {
                    Text("CourseMark")
                    Text("Academic planner with assignments, study tasks, calendar tracking, and reminders.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(
        remindersEnabled: .constant(true),
        reminderTime: .constant(Date())
    )
}
