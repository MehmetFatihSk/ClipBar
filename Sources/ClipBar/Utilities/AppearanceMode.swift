import AppKit
import SwiftUI

/// Manual light/dark switch — a simple two-state toggle (no "system" option).
enum AppearanceMode: String {
    case light
    case dark

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }

    /// SwiftUI's `.preferredColorScheme` only affects semantic colors inside SwiftUI content —
    /// it doesn't repaint the surrounding NSPanel (the MenuBarExtra popover's own vibrancy
    /// material). Forcing `NSApp.appearance` is what actually flips the whole panel.
    var nsAppearance: NSAppearance? {
        switch self {
        case .light: return NSAppearance(named: .aqua)
        case .dark: return NSAppearance(named: .darkAqua)
        }
    }

    static func apply(rawValue: String) {
        let mode = AppearanceMode(rawValue: rawValue) ?? .light
        NSApp.appearance = mode.nsAppearance
    }

    var symbolName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var label: String {
        switch self {
        case .light: return "Açık mod"
        case .dark: return "Koyu mod"
        }
    }

    var next: AppearanceMode {
        switch self {
        case .light: return .dark
        case .dark: return .light
        }
    }
}
