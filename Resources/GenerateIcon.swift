import AppKit

let sizes: [(Int, String)] = [
    (16, "icon_16x16"),
    (32, "icon_16x16@2x"),
    (32, "icon_32x32"),
    (64, "icon_32x32@2x"),
    (128, "icon_128x128"),
    (256, "icon_128x128@2x"),
    (256, "icon_256x256"),
    (512, "icon_256x256@2x"),
    (512, "icon_512x512"),
    (1024, "icon_512x512@2x"),
]

let outputDir = URL(fileURLWithPath: CommandLine.arguments[1])
try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

extension NSImage {
    func tinted(with color: NSColor) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.set()
        let rect = NSRect(origin: .zero, size: size)
        rect.fill()
        draw(at: .zero, from: .zero, operation: .destinationIn, fraction: 1.0)
        image.unlockFocus()
        return image
    }
}

func drawIcon(size: Int) -> NSImage {
    let canvas = NSImage(size: NSSize(width: size, height: size))
    canvas.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = CGFloat(size) * 0.2237
    let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    path.addClip()

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.42, green: 0.47, blue: 0.99, alpha: 1.0),
        NSColor(calibratedRed: 0.24, green: 0.20, blue: 0.80, alpha: 1.0),
    ])
    gradient?.draw(in: rect, angle: -90)

    let config = NSImage.SymbolConfiguration(pointSize: CGFloat(size) * 0.5, weight: .semibold)
    if let symbol = NSImage(systemSymbolName: "doc.on.clipboard.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) {
        let tinted = symbol.tinted(with: .white)
        let symSize = tinted.size
        let x = (CGFloat(size) - symSize.width) / 2
        let y = (CGFloat(size) - symSize.height) / 2
        tinted.draw(at: NSPoint(x: x, y: y), from: .zero, operation: .sourceOver, fraction: 1.0)
    }

    canvas.unlockFocus()
    return canvas
}

for (px, name) in sizes {
    let image = drawIcon(size: px)
    guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { continue }
    let url = outputDir.appendingPathComponent("\(name).png")
    try? png.write(to: url)
    print("wrote \(url.path)")
}
