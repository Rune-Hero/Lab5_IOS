import Foundation
import SwiftUI

// ObservableObject для реактивного управління налаштуваннями
// Всі зміни автоматично зберігаються в UserDefaults через didSet
class AppSettings: ObservableObject {
    // Кольорова тема додатку
    @Published var selectedTheme: ColorTheme {
        didSet {
            // Автоматичне збереження в UserDefaults при зміні
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
            print("💾 Збережено тему: \(selectedTheme.rawValue)")
        }
    }
    
    // Розмір шрифту
    @Published var fontSize: FontSize {
        didSet {
            // Автоматичне збереження в UserDefaults при зміні
            UserDefaults.standard.set(fontSize.rawValue, forKey: "fontSize")
            print("💾 Збережено розмір шрифту: \(fontSize.rawValue)")
        }
    }
    
    // Темний режим
    @Published var isDarkMode: Bool {
        didSet {
            // Автоматичне збереження в UserDefaults при зміні
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            print("💾 Збережено темний режим: \(isDarkMode)")
        }
    }
    
    // Показувати ціну в списку
    @Published var showPriceInPicker: Bool {
        didSet {
            // Автоматичне збереження в UserDefaults при зміні
            UserDefaults.standard.set(showPriceInPicker, forKey: "showPriceInPicker")
            print("💾 Збережено показ ціни: \(showPriceInPicker)")
        }
    }
    
    // Ініціалізація з завантаженням збережених налаштувань
    init() {
        // Завантажуємо збережену тему або використовуємо синю за замовчуванням
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? ColorTheme.blue.rawValue
        self.selectedTheme = ColorTheme(rawValue: savedTheme) ?? .blue
        
        // Завантажуємо збережений розмір шрифту або середній за замовчуванням
        let savedFontSize = UserDefaults.standard.string(forKey: "fontSize") ?? FontSize.medium.rawValue
        self.fontSize = FontSize(rawValue: savedFontSize) ?? .medium
        
        // Завантажуємо налаштування темного режиму
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        // Завантажуємо налаштування показу ціни (за замовчуванням true)
        self.showPriceInPicker = UserDefaults.standard.object(forKey: "showPriceInPicker") as? Bool ?? true
        
        print("✅ Налаштування завантажено з UserDefaults:")
        print("   - Тема: \(selectedTheme.rawValue)")
        print("   - Розмір: \(fontSize.rawValue)")
        print("   - Темний режим: \(isDarkMode)")
        print("   - Показ ціни: \(showPriceInPicker)")
    }
}

enum ColorTheme: String, CaseIterable {
    case blue = "Синій"
    case purple = "Фіолетовий"
    case green = "Зелений"
    case orange = "Помаранчевий"
    case red = "Червоний"
    
    var gradientColors: [Color] {
        switch self {
        case .blue:
            return [Color.blue.opacity(0.15), Color.cyan.opacity(0.15), Color.blue.opacity(0.1)]
        case .purple:
            return [Color.purple.opacity(0.15), Color.pink.opacity(0.15), Color.purple.opacity(0.1)]
        case .green:
            return [Color.green.opacity(0.15), Color.mint.opacity(0.15), Color.green.opacity(0.1)]
        case .orange:
            return [Color.orange.opacity(0.15), Color.yellow.opacity(0.15), Color.orange.opacity(0.1)]
        case .red:
            return [Color.red.opacity(0.15), Color.pink.opacity(0.15), Color.red.opacity(0.1)]
        }
    }
    
    var darkGradientColors: [Color] {
        switch self {
        case .blue:
            return [Color.blue.opacity(0.3), Color.cyan.opacity(0.3), Color.blue.opacity(0.2)]
        case .purple:
            return [Color.purple.opacity(0.3), Color.pink.opacity(0.3), Color.purple.opacity(0.2)]
        case .green:
            return [Color.green.opacity(0.3), Color.mint.opacity(0.3), Color.green.opacity(0.2)]
        case .orange:
            return [Color.orange.opacity(0.3), Color.yellow.opacity(0.3), Color.orange.opacity(0.2)]
        case .red:
            return [Color.red.opacity(0.3), Color.pink.opacity(0.3), Color.red.opacity(0.2)]
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .green: return .green
        case .orange: return .orange
        case .red: return .red
        }
    }
}

enum FontSize: String, CaseIterable {
    case small = "Малий"
    case medium = "Середній"
    case large = "Великий"
    
    var titleSize: CGFloat {
        switch self {
        case .small: return 28
        case .medium: return 34
        case .large: return 40
        }
    }
    
    var headlineSize: CGFloat {
        switch self {
        case .small: return 15
        case .medium: return 17
        case .large: return 20
        }
    }
    
    var bodySize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
    
    var captionSize: CGFloat {
        switch self {
        case .small: return 11
        case .medium: return 12
        case .large: return 14
        }
    }
}
