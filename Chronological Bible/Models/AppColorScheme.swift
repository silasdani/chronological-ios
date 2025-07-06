import Foundation

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { self.rawValue }
    var label: String {
        switch self {
        case .system: return "System Default"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
} 