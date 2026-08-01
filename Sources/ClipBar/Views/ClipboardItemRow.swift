import SwiftUI

struct ClipboardItemRow: View {
    let item: ClipboardItem

    @EnvironmentObject private var manager: ClipboardManager
    @State private var isHovering = false
    @State private var didCopy = false

    var body: some View {
        HStack(spacing: 10) {
            ClipboardThumbnail(item: item)
            content
            Spacer(minLength: 8)
            copyButton
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isHovering ? Color.primary.opacity(0.06) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onHover { isHovering = $0 }
        .contentShape(Rectangle())
        .onTapGesture { handlePrimaryTap() }
        .contextMenu {
            Button {
                manager.togglePin(item)
            } label: {
                Label(item.isPinned ? "Sabitten Çıkar" : "Sabitle", systemImage: item.isPinned ? "pin.slash" : "pin")
            }
            Button("Sil", role: .destructive) { manager.remove(item) }
        }
    }

    private func handlePrimaryTap() {
        switch item.type {
        case .link:
            if let text = item.text, let url = ContentDetector.detectURL(in: text) {
                NSWorkspace.shared.open(url)
            }
        case .text, .color, .image:
            break
        }
    }

    @ViewBuilder private var content: some View {
        VStack(alignment: .leading, spacing: 2) {
            switch item.type {
            case .color:
                Text(item.text ?? "")
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
            case .image:
                Text("Görsel")
                    .font(.body)
            case .link, .text:
                Text(item.text ?? "")
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            TimelineView(.periodic(from: item.date, by: 60)) { _ in
                Text(RelativeDateLabel.string(for: item.date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var copyButton: some View {
        Button {
            manager.copyToPasteboard(item)
            didCopy = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { didCopy = false }
        } label: {
            Image(systemName: didCopy ? "checkmark.circle.fill" : "doc.on.doc")
                .foregroundStyle(didCopy ? .green : .secondary)
        }
        .buttonStyle(.plain)
        .help("Panoya kopyala")
    }
}
