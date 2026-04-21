import Foundation

struct Assignment: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var courseName: String
    var dueDate: Date
    var priority: String
    var type: String
    var notes: String
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        courseName: String,
        dueDate: Date,
        priority: String,
        type: String,
        notes: String,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.courseName = courseName
        self.dueDate = dueDate
        self.priority = priority
        self.type = type
        self.notes = notes
        self.isCompleted = isCompleted
    }
}
