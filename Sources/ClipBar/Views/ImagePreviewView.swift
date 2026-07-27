import SwiftUI

struct ImagePreviewView: View {
    let itemID: UUID?
    @EnvironmentObject private var manager: ClipboardManager

    private var item: ClipboardItem? {
        manager.items.first { $0.id == itemID }
    }

    var body: some View {
        Group {
            if let item, let nsImage = manager.image(for: item) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Text("Görsel bulunamadı")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .frame(minWidth: 320, minHeight: 240)
    }
}
