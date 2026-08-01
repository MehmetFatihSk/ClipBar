import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var manager: ClipboardManager
    @StateObject private var hoverController = HoverPreviewController()
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.light.rawValue
    @Environment(\.openWindow) private var openWindow

    private let panelSize = CGSize(width: 340, height: 440)

    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .light
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if manager.items.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(manager.displayItems) { item in
                            ClipboardItemRow(item: item)
                        }
                    }
                    .padding(6)
                }
            }

            Divider()
            footer
        }
        .frame(width: panelSize.width, height: panelSize.height)
        .environmentObject(hoverController)
        .overlayPreferenceValue(HoverAnchorKey.self) { anchors in
            GeometryReader { proxy in
                if let item = hoverController.hoveredItem, let anchor = anchors[item.id] {
                    let rect = proxy[anchor]
                    HoverPreviewOverlay(item: item)
                        .position(x: panelSize.width / 2, y: clampedY(for: rect.midY))
                }
            }
        }
        .clipped()
    }

    private func clampedY(for anchorMidY: CGFloat) -> CGFloat {
        let margin: CGFloat = 110
        return min(max(anchorMidY, margin), panelSize.height - margin)
    }

    private var header: some View {
        HStack {
            Text("ClipBar")
                .font(.headline)
            Spacer()
            Text("\(manager.items.count)/\(manager.maxItems)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                let next = appearance.next
                appearanceRaw = next.rawValue
                AppearanceMode.apply(rawValue: next.rawValue)
            } label: {
                Image(systemName: appearance.symbolName)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help(appearance.label)
            Button {
                manager.clearAll()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Tümünü temizle")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clipboard")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Henüz bir şey kopyalanmadı")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var footer: some View {
        HStack {
            Button {
                openSettings()
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Ayarlar")

            Spacer()
            Button("Çıkış") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }

    private func openSettings() {
        if let existing = NSApp.windows.first(where: { $0.title == "Ayarlar" }) {
            existing.makeKeyAndOrderFront(nil)
        } else {
            openWindow(id: "settings")
        }
        NSApp.activate(ignoringOtherApps: true)
    }
}
