import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var manager: ClipboardManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ayarlar")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Stepper(value: $manager.maxItems, in: ClipboardManager.maxItemsRange) {
                    Text("Gösterilecek kopya sayısı: \(manager.maxItems)")
                }
                Text("Varsayılan: \(ClipboardManager.defaultMaxItems) · En fazla: \(ClipboardManager.maxItemsRange.upperBound)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 340, height: 440, alignment: .top)
    }
}
