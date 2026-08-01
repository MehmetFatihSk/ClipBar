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
    var isPinned: Bool = false

    init(id: UUID = UUID(), type: ClipboardItemType, text: String? = nil, imageFileName: String? = nil, date: Date = Date(), isPinned: Bool = false) {
        self.id = id
        self.type = type
        self.text = text
        self.imageFileName = imageFileName
        self.date = date
        self.isPinned = isPinned
    }

    private enum CodingKeys: String, CodingKey {
        case id, type, text, imageFileName, date, isPinned
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(ClipboardItemType.self, forKey: .type)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        imageFileName = try container.decodeIfPresent(String.self, forKey: .imageFileName)
        date = try container.decode(Date.self, forKey: .date)
        // Older history.json files predate pinning — default to unpinned instead of failing to load.
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }
}
