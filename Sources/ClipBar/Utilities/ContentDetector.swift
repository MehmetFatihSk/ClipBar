import Foundation

enum ContentDetector {
    /// Returns a normalized "#RRGGBB" / "#RGB" string if `string` is nothing but a hex color code.
    static func detectColorHex(in string: String) -> String? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = "^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$"
        guard trimmed.range(of: pattern, options: .regularExpression) != nil else { return nil }
        return trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"
    }

    /// Returns a URL if the entire string is a single link (not just text that contains a link).
    static func detectURL(in string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        guard let match = detector.firstMatch(in: trimmed, range: range),
              match.range == range,
              let url = match.url else { return nil }
        return url
    }
}
