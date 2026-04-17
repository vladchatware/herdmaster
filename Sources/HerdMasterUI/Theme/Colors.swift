#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI

enum HMColor {
    static let background = Color(hex: 0x0F172A)
    static let surface = Color(hex: 0x1E293B)
    static let surfaceElevated = Color(hex: 0x334155)
    static let divider = Color(hex: 0x475569)

    static let textPrimary = Color(hex: 0xF8FAFC)
    static let textSecondary = Color(hex: 0xCBD5E1)
    static let textMuted = Color(hex: 0x94A3B8)

    static let accent = Color(hex: 0x14B8A6)
    static let accentDark = Color(hex: 0x0F766E)
    static let accentLight = Color(hex: 0x5EEAD4)

    static let success = Color(hex: 0x22C55E)
    static let warning = Color(hex: 0xF59E0B)
    static let danger = Color(hex: 0xEF4444)

    enum Pedigree {
        static let male = Color(hex: 0x3B82F6)
        static let maleSurface = Color(hex: 0xDBEAFE)
        static let female = Color(hex: 0xEC4899)
        static let femaleSurface = Color(hex: 0xFCE7F3)
        static let neuter = Color(hex: 0x22C55E)
        static let neuterSurface = Color(hex: 0xDCFCE7)
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
#endif
