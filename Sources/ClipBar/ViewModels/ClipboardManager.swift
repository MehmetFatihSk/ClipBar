import AppKit
import Combine
import SwiftUI

@MainActor
final class ClipboardManager: ObservableObject {
    static let maxItems = 25
    /// Polling interval for NSPasteboard.changeCount. macOS has no push notification for
    /// clipboard changes, so this is the standard approach — the check itself is a cheap
    /// integer comparison and only does real work when the count actually changes.
    private static let pollInterval: TimeInterval = 0.4

    @Published private(set) var items: [ClipboardItem] = []

    private let store = PersistenceStore()
    private var timer: Timer?
    private var lastChangeCount: Int
    private var imageCache: [UUID: NSImage] = [:]

    init() {
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
        if items.count > Self.maxItems {
            let overflow = items.suffix(from: Self.maxItems)
            for old in overflow {
                if old.type == .image, let fileName = old.imageFileName {
                    store.deleteImage(fileName: fileName)
                }
                imageCache.removeValue(forKey: old.id)
            }
            items.removeLast(items.count - Self.maxItems)
        }
        store.saveItems(items)
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
