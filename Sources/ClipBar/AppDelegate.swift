import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Pure menu bar app: no Dock icon, no app switcher entry.
        NSApp.setActivationPolicy(.accessory)
    }
}
