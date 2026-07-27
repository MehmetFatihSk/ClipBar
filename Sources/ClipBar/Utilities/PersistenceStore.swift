import AppKit
import Foundation

/// Reads/writes the clipboard history to `~/Library/Application Support/ClipBar`.
/// Text/link/color metadata lives in a single JSON file; each image is its own PNG file
/// so the JSON stays small regardless of image size.
final class PersistenceStore {
    private let historyFileName = "history.json"

    private lazy var rootDirectory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("ClipBar", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private lazy var imagesDirectory: URL = {
        let dir = rootDirectory.appendingPathComponent("Images", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private var historyFileURL: URL { rootDirectory.appendingPathComponent(historyFileName) }

    func loadItems() -> [ClipboardItem] {
        guard let data = try? Data(contentsOf: historyFileURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([ClipboardItem].self, from: data)) ?? []
    }

    func saveItems(_ items: [ClipboardItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: historyFileURL, options: .atomic)
    }

    @discardableResult
    func saveImage(_ image: NSImage) -> String? {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let pngData = rep.representation(using: .png, properties: [:]) else { return nil }

        let fileName = "\(UUID().uuidString).png"
        let url = imagesDirectory.appendingPathComponent(fileName)
        do {
            try pngData.write(to: url)
            return fileName
        } catch {
            return nil
        }
    }

    func loadImage(fileName: String) -> NSImage? {
        NSImage(contentsOf: imagesDirectory.appendingPathComponent(fileName))
    }

    func deleteImage(fileName: String) {
        try? FileManager.default.removeItem(at: imagesDirectory.appendingPathComponent(fileName))
    }
}
