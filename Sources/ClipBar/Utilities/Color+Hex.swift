import SwiftUI

extension Color {
    init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        if hexString.count == 3 {
            hexString = hexString.map { "\($0)\($0)" }.joined()
        }
        guard hexString.count == 6, let value = UInt64(hexString, radix: 16) else { return nil }

        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self = Color(red: r, green: g, blue: b)
    }
}
