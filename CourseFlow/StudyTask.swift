import Foundation

struct StudyTask: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var courseName: String
    var date: Date
    var isCompleted: Bool = false
}
