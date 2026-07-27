import SwiftUI

/// Manual light/dark override. "System" follows macOS automatically (the default);
/// Light/Dark force a scheme regardless of the system setting.
enum AppearanceMode: String {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var symbolName: String {
        switch self {
        case .system: return "circle.righthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var label: String {
        switch self {
        case .system: return "Sistemi izle"
        case .light: return "Açık mod"
        case .dark: return "Koyu mod"
        }
    }

    var next: AppearanceMode {
        switch self {
        case .system: return .light
        case .light: return .dark
        case .dark: return .system
        }
    }
}
