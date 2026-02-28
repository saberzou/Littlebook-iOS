import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDark: Bool {
        didSet { UserDefaults.standard.set(isDark, forKey: "isDark") }
    }

    init() {
        if UserDefaults.standard.object(forKey: "isDark") != nil {
            isDark = UserDefaults.standard.bool(forKey: "isDark")
        } else {
            isDark = true
        }
    }

    var colorScheme: ColorScheme { isDark ? .dark : .light }
}
