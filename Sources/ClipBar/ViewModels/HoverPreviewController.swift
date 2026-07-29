import Foundation

/// Single source of truth for "which item is currently enlarged on hover".
/// Only one item can be hovered at a time; a scheduled hide is only honored if
/// nothing newer has taken over in the meantime, so quick moves between thumbnails
/// can't leave a stale preview stuck on screen.
@MainActor
final class HoverPreviewController: ObservableObject {
    @Published private(set) var hoveredItem: ClipboardItem?
    private var hideWorkItem: DispatchWorkItem?

    func show(_ item: ClipboardItem) {
        hideWorkItem?.cancel()
        hoveredItem = item
    }

    func scheduleHide(for item: ClipboardItem) {
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.hoveredItem?.id == item.id else { return }
            self.hoveredItem = nil
        }
        hideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: work)
    }
}
