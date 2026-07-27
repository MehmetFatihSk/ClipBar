import Foundation

enum ClipboardItemType: String, Codable {
    case text
    case link
    case color
    case image
}

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ClipboardItemType
    /// Plain text, link string, or "#RRGGBB" hex code depending on `type`. Nil for `.image`.
    let text: String?
    /// Filename (not full path) of the PNG stored under the images directory. Only set for `.image`.
    let imageFileName: String?
    let date: Date

    init(id: UUID = UUID(), type: ClipboardItemType, text: String? = nil, imageFileName: String? = nil, date: Date = Date()) {
        self.id = id
        self.type = type
        self.text = text
        self.imageFileName = imageFileName
        self.date = date
    }
}
