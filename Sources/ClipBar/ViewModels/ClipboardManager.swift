import AppKit
import Combine
import SwiftUI

@MainActor
final class ClipboardManager: ObservableObject {
    static let defaultMaxItems = 25
    static let maxItemsRange = 1...100
    private static let maxItemsDefaultsKey = "maxItems"

    /// Polling interval for NSPasteboard.changeCount. macOS has no push notification for
    /// clipboard changes, so this is the standard approach — the check itself is a cheap
    /// integer comparison and only does real work when the count actually changes.
    private static let pollInterval: TimeInterval = 0.4

    @Published private(set) var items: [ClipboardItem] = []

    /// User-configurable history size (Settings window). Always starts at `defaultMaxItems`
    /// for a fresh install; persisted after that.
    @Published var maxItems: Int {
        didSet {
            UserDefaults.standard.set(maxItems, forKey: Self.maxItemsDefaultsKey)
            trimToMaxItems()
            store.saveItems(items)
        }
    }

    /// Items for display: pinned items first (in their own recency order), then the rest —
    /// pinning never reorders the underlying chronological `items` storage.
    var displayItems: [ClipboardItem] {
        items.filter(\.isPinned) + items.filter { !$0.isPinned }
    }

    private let store = PersistenceStore()
    private var timer: Timer?
    private var lastChangeCount: Int
    private var imageCache: [UUID: NSImage] = [:]

    init() {
        let saved = UserDefaults.standard.object(forKey: Self.maxItemsDefaultsKey) as? Int
        maxItems = saved.map { min(max($0, Self.maxItemsRange.lowerBound), Self.maxItemsRange.upperBound) } ?? Self.defaultMaxItems

        lastChangeCount = NSPasteboard.general.changeCount
        items = store.loadItems()
        preloadImageCache()
        startPolling()
    }

    deinit {
        timer?.invalidate()
    }

    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: Self.pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.checkPasteboard() }
        }
    }

    private func preloadImageCache() {
        for item in items where item.type == .image {
            if let fileName = item.imageFileName, let image = store.loadImage(fileName: fileName) {
                imageCache[item.id] = image
            }
        }
    }

    // MARK: - Pasteboard polling

    private func checkPasteboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if let image = NSImage(pasteboard: pasteboard), pasteboardContainsImage(pasteboard) {
            addImageItem(image)
        } else if let string = pasteboard.string(forType: .string), !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            addTextItem(string)
        }
    }

    private func pasteboardContainsImage(_ pasteboard: NSPasteboard) -> Bool {
        let imageTypes: [NSPasteboard.PasteboardType] = [.tiff, .png]
        return pasteboard.types?.contains(where: imageTypes.contains) ?? false
    }

    private func addTextItem(_ string: String) {
        // Avoid re-adding the same content back-to-back (e.g. our own quick-copy writes).
        if let top = items.first, top.type != .image, top.text == string { return }

        let type: ClipboardItemType
        let normalized: String
        if let hex = ContentDetector.detectColorHex(in: string) {
            type = .color
            normalized = hex
        } else if ContentDetector.detectURL(in: string) != nil {
            type = .link
            normalized = string
        } else {
            type = .text
            normalized = string
        }

        insert(ClipboardItem(type: type, text: normalized))
    }

    private func addImageItem(_ image: NSImage) {
        if let top = items.first, top.type == .image, let topFileName = top.imageFileName,
           let cached = imageCache[top.id], imagesAreEqual(cached, image) {
            _ = topFileName
            return
        }
        guard let fileName = store.saveImage(image) else { return }
        let item = ClipboardItem(type: .image, imageFileName: fileName)
        imageCache[item.id] = image
        insert(item)
    }

    private func imagesAreEqual(_ lhs: NSImage, _ rhs: NSImage) -> Bool {
        lhs.tiffRepresentation == rhs.tiffRepresentation
    }

    private func insert(_ item: ClipboardItem) {
        items.insert(item, at: 0)
        trimToMaxItems()
        store.saveItems(items)
    }

    /// Evicts the oldest *unpinned* items until the unpinned count fits within the
    /// configured limit — pinned items are never evicted, even if that means the total
    /// count temporarily exceeds `maxItems`.
    private func trimToMaxItems() {
        let pinnedCount = items.filter(\.isPinned).count
        let allowedUnpinned = max(0, maxItems - pinnedCount)
        var unpinnedToRemove = (items.count - pinnedCount) - allowedUnpinned
        guard unpinnedToRemove > 0 else { return }

        var index = items.count - 1
        while unpinnedToRemove > 0 && index >= 0 {
            if !items[index].isPinned {
                let old = items[index]
                if old.type == .image, let fileName = old.imageFileName {
                    store.deleteImage(fileName: fileName)
                }
                imageCache.removeValue(forKey: old.id)
                items.remove(at: index)
                unpinnedToRemove -= 1
            }
            index -= 1
        }
    }

    // MARK: - User actions

    func copyToPasteboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.type {
        case .text, .link, .color:
            pasteboard.setString(item.text ?? "", forType: .string)
        case .image:
            if let image = image(for: item) {
                pasteboard.writeObjects([image])
            }
        }
        // We caused this change ourselves — don't let the next poll re-capture it as a new item.
        lastChangeCount = pasteboard.changeCount
    }

    func image(for item: ClipboardItem) -> NSImage? {
        if let cached = imageCache[item.id] { return cached }
        guard let fileName = item.imageFileName, let image = store.loadImage(fileName: fileName) else { return nil }
        imageCache[item.id] = image
        return image
    }

    func togglePin(_ item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isPinned.toggle()
        store.saveItems(items)
    }

    func remove(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        if item.type == .image, let fileName = item.imageFileName {
            store.deleteImage(fileName: fileName)
        }
        imageCache.removeValue(forKey: item.id)
        store.saveItems(items)
    }

    func clearAll() {
        for item in items where item.type == .image {
            if let fileName = item.imageFileName {
                store.deleteImage(fileName: fileName)
            }
        }
        items.removeAll()
        imageCache.removeAll()
        store.saveItems(items)
    }
}
