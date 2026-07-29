import SwiftUI

/// The enlarged color/image card shown while hovering a thumbnail. Purely visual —
/// never intercepts mouse events, so it can never itself trigger a hover change.
struct HoverPreviewOverlay: View {
    let item: ClipboardItem
    @EnvironmentObject private var manager: ClipboardManager

    var body: some View {
        Group {
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
                            .frame(maxWidth: 200, maxHeight: 200)
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
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.primary.opacity(0.1)))
        .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
        .allowsHitTesting(false)
    }
}
