import SwiftUI

/// Settings screen content — shown in-place inside the same menu bar popover
/// (not a separate window), navigated to via the gear icon in the footer.
struct SettingsView: View {
    @EnvironmentObject private var manager: ClipboardManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Stepper(value: $manager.maxItems, in: ClipboardManager.maxItemsRange) {
                Text("Gösterilecek kopya sayısı: \(manager.maxItems)")
                    .font(.callout)
            }
            Text("Varsayılan: \(ClipboardManager.defaultMaxItems) · En fazla: \(ClipboardManager.maxItemsRange.upperBound)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
