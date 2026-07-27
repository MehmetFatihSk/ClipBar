import SwiftUI

/// The small color-swatch / image thumbnail shown at the left of a row.
/// Hovering over it automatically shows an enlarged preview (no click needed);
/// clicking it only opens the full image preview window (images only).
struct ClipboardThumbnail: View {
    let item: ClipboardItem

    @EnvironmentObject private var manager: ClipboardManager
    @Environment(\.openWindow) private var openWindow
    @State private var isPreviewShown = false
    @State private var hideWorkItem: DispatchWorkItem?

    var body: some View {
        thumbnail
            .contentShape(Rectangle())
            .onHover(perform: handleHover)
            .onTapGesture {
                if item.type == .image {
                    openWindow(value: item.id)
                }
            }
            .popover(isPresented: $isPreviewShown, arrowEdge: .trailing) {
                enlargedPreview
            }
    }

    private func handleHover(_ hovering: Bool) {
        guard item.type == .image || item.type == .color else { return }
        if hovering {
            hideWorkItem?.cancel()
            isPreviewShown = true
        } else {
            let work = DispatchWorkItem { isPreviewShown = false }
            hideWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: work)
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

    @ViewBuilder private var enlargedPreview: some View {
        switch item.type {
        case .color:
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: item.text ?? "") ?? .gray)
                    .frame(width: 100, height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary.opacity(0.15)))
                Text(item.text ?? "")
                    .font(.system(.body, design: .monospaced))
            }
            .padding(14)
        case .image:
            Group {
                if let nsImage = manager.image(for: item) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 260, maxHeight: 260)
                } else {
                    Text("Görsel bulunamadı")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
        case .link, .text:
            EmptyView()
        }
    }
}
