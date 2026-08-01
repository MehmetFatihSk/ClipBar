import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var manager: ClipboardManager
    @StateObject private var hoverController = HoverPreviewController()
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.light.rawValue
    @State private var showingSettings = false

    private let panelWidth: CGFloat = 340
    private let listPanelHeight: CGFloat = 440
    private let settingsPanelHeight: CGFloat = 128

    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .light
    }

    var body: some View {
        if showingSettings {
            settingsScreen
        } else {
            listScreen
        }
    }

    private var listScreen: some View {
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
        .frame(width: panelWidth, height: listPanelHeight)
        .environmentObject(hoverController)
        .overlayPreferenceValue(HoverAnchorKey.self) { anchors in
            GeometryReader { proxy in
                if let item = hoverController.hoveredItem, let anchor = anchors[item.id] {
                    let rect = proxy[anchor]
                    HoverPreviewOverlay(item: item)
                        .position(x: panelWidth / 2, y: clampedY(for: rect.midY))
                }
            }
        }
        .clipped()
    }

    private var settingsScreen: some View {
        VStack(spacing: 0) {
            settingsHeader
            Divider()
            SettingsView()
            Spacer(minLength: 0)
            Divider()
            settingsFooter
        }
        .frame(width: panelWidth, height: settingsPanelHeight)
    }

    private func clampedY(for anchorMidY: CGFloat) -> CGFloat {
        let margin: CGFloat = 110
        return min(max(anchorMidY, margin), listPanelHeight - margin)
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
                showingSettings = true
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

    private var settingsHeader: some View {
        HStack {
            Text("Ayarlar")
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var settingsFooter: some View {
        HStack {
            Button {
                showingSettings = false
            } label: {
                Image(systemName: "chevron.left")
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Geri")
            .padding(.leading, 3)

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
}
