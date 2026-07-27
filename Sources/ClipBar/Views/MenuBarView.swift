import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var manager: ClipboardManager
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.system.rawValue

    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .system
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
                        ForEach(manager.items) { item in
                            ClipboardItemRow(item: item)
                        }
                    }
                    .padding(6)
                }
            }

            Divider()
            footer
        }
        .frame(width: 340, height: 440)
    }

    private var header: some View {
        HStack {
            Text("ClipBar")
                .font(.headline)
            Spacer()
            Text("\(manager.items.count)/\(ClipboardManager.maxItems)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                appearanceRaw = appearance.next.rawValue
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
