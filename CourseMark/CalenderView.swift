import SwiftUI

struct CalendarView: View {
    let courses: [Course]
    @Binding var assignments: [Assignment]
    let studyTasks: [StudyTask]
    let toggleStudyTaskCompletion: (String) -> Void

    @State private var currentMonth = Date()
    @State private var selectedDate = Date()

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                headerView
                daysOfWeekView
                monthGridView

                Divider()
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                selectedDayItemsView
            }
            .padding()
            .navigationTitle("Calendar")
        }
    }
}

// MARK: - Header
extension CalendarView {
    var headerView: some View {
        HStack {
            Button {
                withAnimation(.easeInOut) {
                    changeMonth(by: -1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
            }

            Spacer()

            Text(monthYearString(from: currentMonth))
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button {
                withAnimation(.easeInOut) {
                    changeMonth(by: 1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
            }
        }
    }

    func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Days Row
extension CalendarView {
    var daysOfWeekView: some View {
        let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        return HStack {
            ForEach(symbols, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 4)
    }
}

// MARK: - Grid
extension CalendarView {
    var monthGridView: some View {
        let days = generateDaysForMonth()

        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7),
            spacing: 12
        ) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 62)
                }
            }
        }
    }

    func generateDaysForMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday,
              let dayRange = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }

        var days: [Date?] = []

        let leadingBlanks = firstWeekday - 1
        days.append(contentsOf: Array(repeating: nil, count: leadingBlanks))

        for day in dayRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }

        return days
    }

    func dayCell(for date: Date) -> some View {
        let assignmentItems = assignmentsForDate(date)
        let studyItems = studyTasksForDate(date)

        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let totalCount = assignmentItems.count + studyItems.count

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : (isToday ? .blue : .primary))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(
                                isSelected
                                ? Color.blue
                                : (isToday ? Color.blue.opacity(0.15) : Color.clear)
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                isToday && !isSelected ? Color.blue.opacity(0.5) : Color.clear,
                                lineWidth: 1
                            )
                    )

                HStack(spacing: 3) {
                    ForEach(Array(assignmentItems.prefix(3))) { assignment in
                        Circle()
                            .fill(
                                colorForCourseName(assignment.courseName)
                                    .opacity(assignment.isCompleted ? 0.3 : 1.0)
                            )
                            .frame(width: 6, height: 6)
                    }

                    ForEach(Array(studyItems.prefix(max(0, 3 - assignmentItems.count))), id: \.id) { task in
                        Circle()
                            .stroke(colorForCourseName(task.courseName), lineWidth: 1.5)
                            .background(
                                Circle()
                                    .fill(
                                        task.isCompleted
                                        ? colorForCourseName(task.courseName).opacity(0.25)
                                        : Color.clear
                                    )
                            )
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(height: 8)

                if totalCount > 3 {
                    Text("+\(totalCount - 3)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 62)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Selected Day Items
extension CalendarView {
    var selectedDayItemsView: some View {
        let dayAssignments = assignmentsForDate(selectedDate)
        let dayStudyTasks = studyTasksForDate(selectedDate)

        return ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)

                    Text("Due items and study tasks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if dayAssignments.isEmpty && dayStudyTasks.isEmpty {
                    Text("Nothing due or scheduled.")
                        .foregroundStyle(.secondary)
                } else {
                    if !dayAssignments.isEmpty {
                        Text("Assignments")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ForEach($assignments) { $assignment in
                            if calendar.isDate(assignment.dueDate, inSameDayAs: selectedDate) {
                                HStack(alignment: .top, spacing: 12) {
                                    Button {
                                        assignment.isCompleted.toggle()
                                    } label: {
                                        Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                    }
                                    .buttonStyle(.plain)

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(colorForCourseName(assignment.courseName))
                                                .frame(width: 10, height: 10)

                                            Text(assignment.title)
                                                .font(.headline)
                                                .strikethrough(assignment.isCompleted)
                                                .foregroundStyle(assignment.isCompleted ? .secondary : .primary)
                                        }

                                        Text(assignment.courseName)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        HStack(spacing: 8) {
                                            Text(assignment.type)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)

                                            priorityBadge(assignment.priority)
                                        }
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }

                    if !dayStudyTasks.isEmpty {
                        Text("Study Tasks")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)

                        ForEach(dayStudyTasks) { task in
                            HStack(alignment: .top, spacing: 12) {
                                Button {
                                    toggleStudyTaskCompletion(task.id)
                                } label: {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .stroke(colorForCourseName(task.courseName), lineWidth: 2)
                                            .frame(width: 10, height: 10)

                                        Text(task.title)
                                            .font(.headline)
                                            .strikethrough(task.isCompleted)
                                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                                    }

                                    Text(task.courseName)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Helpers
extension CalendarView {
    func assignmentsForDate(_ date: Date) -> [Assignment] {
        assignments
            .filter { calendar.isDate($0.dueDate, inSameDayAs: date) }
            .sorted { $0.dueDate < $1.dueDate }
    }

    func studyTasksForDate(_ date: Date) -> [StudyTask] {
        studyTasks
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }

    func colorForCourseName(_ courseName: String) -> Color {
        guard let course = courses.first(where: { $0.name == courseName }) else {
            return .gray
        }

        switch course.colorName.lowercased() {
        case "blue":
            return .blue
        case "green":
            return .green
        case "purple":
            return .purple
        case "orange":
            return .orange
        case "red":
            return .red
        default:
            return .gray
        }
    }

    func priorityBadge(_ priority: String) -> some View {
        Text(priority)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priorityColor(priority).opacity(0.15))
            .foregroundStyle(priorityColor(priority))
            .clipShape(Capsule())
    }

    func priorityColor(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "high":
            return .red
        case "medium":
            return .orange
        case "low":
            return .green
        default:
            return .gray
        }
    }
}
