import SwiftUI

class ThemeManager: ObservableObject {
    @Published var selectedTheme: String {
        didSet {
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        }
    }
    
    init() {
        self.selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "system"
    }
    
    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            return nil
        }
    }
}
