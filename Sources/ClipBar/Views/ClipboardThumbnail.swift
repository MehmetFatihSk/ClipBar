import SwiftUI

/// The small color-swatch / image thumbnail shown at the left of a row.
/// Hovering over it reports itself to the shared `HoverPreviewController`, which
/// decides which single item (if any) gets its enlarged preview drawn by the
/// container. Clicking it only opens the full image preview window (images only).
struct ClipboardThumbnail: View {
    let item: ClipboardItem

    @EnvironmentObject private var manager: ClipboardManager
    @EnvironmentObject private var hoverController: HoverPreviewController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        thumbnail
            .contentShape(Rectangle())
            .anchorPreference(key: HoverAnchorKey.self, value: .bounds) { [item.id: $0] }
            .onHover(perform: handleHover)
            .onTapGesture {
                if item.type == .image {
                    openWindow(value: item.id)
                }
            }
    }

    private func handleHover(_ hovering: Bool) {
        guard item.type == .image || item.type == .color else { return }
        if hovering {
            hoverController.show(item)
        } else {
            hoverController.scheduleHide(for: item)
        }
    }

    @ViewBuilder private var thumbnail: some View {
        switch item.type {
        case .color:
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: item.text ?? "") ?? .gray)
                .frame(width: 26, height: 26)
                .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.primary.opacity(0.15)))
        case .image:
            Group {
                if let nsImage = manager.image(for: item) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.secondary.opacity(0.2)
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        case .link:
            Image(systemName: "link")
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 26)
        case .text:
            Image(systemName: "text.alignleft")
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 26)
        }
    }
}
