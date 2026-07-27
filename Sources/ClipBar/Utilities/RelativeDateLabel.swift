import Foundation

/// Formats a past date as "3 dk", "2 sa", "5 gün", "1 ay" etc. — minute granularity at the
/// finest, never seconds, so the row doesn't need to redraw every second.
enum RelativeDateLabel {
    static func string(for date: Date) -> String {
        let seconds = max(0, Int(Date().timeIntervalSince(date)))
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        let months = days / 30

        if minutes < 1 { return "az önce" }
        if hours < 1 { return "\(minutes) dk" }
        if days < 1 { return "\(hours) sa" }
        if days < 30 { return "\(days) gün" }
        return "\(months) ay"
    }
}
