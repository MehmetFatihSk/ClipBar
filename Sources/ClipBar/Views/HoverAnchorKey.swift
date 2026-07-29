import SwiftUI

/// Reports each thumbnail's on-screen bounds up to the container so the hover
/// preview overlay can be positioned near whichever one is currently hovered.
struct HoverAnchorKey: PreferenceKey {
    static var defaultValue: [UUID: Anchor<CGRect>] = [:]

    static func reduce(value: inout [UUID: Anchor<CGRect>], nextValue: () -> [UUID: Anchor<CGRect>]) {
        value.merge(nextValue()) { _, new in new }
    }
}
