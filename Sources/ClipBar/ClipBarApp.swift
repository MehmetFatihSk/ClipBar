import SwiftUI

@main
struct ClipBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var manager = ClipboardManager()
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.light.rawValue

    private var colorScheme: ColorScheme {
        (AppearanceMode(rawValue: appearanceRaw) ?? .light).colorScheme
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(manager)
                .preferredColorScheme(colorScheme)
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
        .menuBarExtraStyle(.window)

        WindowGroup("Önizleme", for: UUID.self) { $itemID in
            ImagePreviewView(itemID: itemID)
                .environmentObject(manager)
                .preferredColorScheme(colorScheme)
        }
    }
}
