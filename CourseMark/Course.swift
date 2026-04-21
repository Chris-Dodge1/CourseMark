import Foundation

struct Course: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var instructor: String
    var colorName: String

    init(id: UUID = UUID(), name: String, instructor: String, colorName: String) {
        self.id = id
        self.name = name
        self.instructor = instructor
        self.colorName = colorName
    }
}
