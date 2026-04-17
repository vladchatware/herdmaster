import SwiftUI

enum HMFont {
    static func displayLarge() -> Font {
        .system(size: 32, weight: .bold, design: .serif)
    }

    static func displayMedium() -> Font {
        .system(size: 28, weight: .semibold, design: .serif)
    }

    static func heading() -> Font {
        .system(size: 22, weight: .semibold, design: .serif)
    }

    static func title() -> Font {
        .system(size: 17, weight: .semibold)
    }

    static func body() -> Font {
        .system(size: 15, weight: .regular)
    }

    static func bodyStrong() -> Font {
        .system(size: 15, weight: .medium)
    }

    static func caption() -> Font {
        .system(size: 13, weight: .regular)
    }

    static func captionStrong() -> Font {
        .system(size: 13, weight: .medium)
    }

    static func micro() -> Font {
        .system(size: 11, weight: .semibold)
    }

    static func statLarge() -> Font {
        .system(size: 36, weight: .bold, design: .rounded)
    }
}
