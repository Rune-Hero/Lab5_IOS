import SwiftUI

struct SavedDataView: View {
    @ObservedObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var savedCoins: [CoinItem] = []
    @State private var savedDate: Date?
    @State private var fileSize: String = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: settings.isDarkMode ?
                        settings.selectedTheme.darkGradientColors :
                        settings.selectedTheme.gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Інформація про файл
                        if let date = savedDate {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(settings.selectedTheme.primaryColor)
                                        .font(.system(size: settings.fontSize.headlineSize))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Дані збережено")
                                            .font(.system(size: settings.fontSize.headlineSize))
                                            .bold()
                                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                                        
                                        Text(formatDate(date))
                                            .font(.system(size: settings.fontSize.bodySize))
                                            .foregroundColor(settings.isDarkMode ? .white.opacity(0.8) : .secondary)
                                        
                                        Text(timeAgo(from: date))
                                            .font(.system(size: settings.fontSize.captionSize))
                                            .foregroundColor(settings.selectedTheme.primaryColor)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                    .background(settings.isDarkMode ? .white.opacity(0.3) : .gray.opacity(0.3))
                                
                                HStack {
                                    Image(systemName: "doc.fill")
                                        .foregroundColor(settings.selectedTheme.primaryColor)
                                        .font(.system(size: settings.fontSize.bodySize))
                                    
                                    Text("Розмір файлу:")
                                        .font(.system(size: settings.fontSize.bodySize))
                                        .foregroundColor(settings.isDarkMode ? .white : .primary)
                                    
                                    Spacer()
                                    
                                    Text(fileSize)
                                        .font(.system(size: settings.fontSize.bodySize))
                                        .bold()
                                        .foregroundColor(settings.selectedTheme.primaryColor)
                                }
                                
                                HStack {
                                    Image(systemName: "bitcoinsign.circle.fill")
                                        .foregroundColor(settings.selectedTheme.primaryColor)
                                        .font(.system(size: settings.fontSize.bodySize))
                                    
                                    Text("Кількість валют:")
                                        .font(.system(size: settings.fontSize.bodySize))
                                        .foregroundColor(settings.isDarkMode ? .white : .primary)
                                    
                                    Spacer()
                                    
                                    Text("\(savedCoins.count)")
                                        .font(.system(size: settings.fontSize.bodySize))
                                        .bold()
                                        .foregroundColor(settings.selectedTheme.primaryColor)
                                }
                            }
                            .padding()
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        
                        // Список криптовалют
                        if isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(settings.selectedTheme.primaryColor)
                                
                                Text("Завантаження даних...")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                    .foregroundColor(settings.isDarkMode ? .white.opacity(0.8) : .secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        } else if let error = errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.orange)
                                
                                Text(error)
                                    .font(.system(size: settings.fontSize.bodySize))
                                    .foregroundColor(settings.isDarkMode ? .white : .primary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        } else if savedCoins.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(settings.isDarkMode ? .white.opacity(0.5) : .gray)
                                
                                Text("Немає збережених даних")
                                    .font(.system(size: settings.fontSize.headlineSize))
                                    .foregroundColor(settings.isDarkMode ? .white : .primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(savedCoins) { coin in
                                    CoinCardView(coin: coin, settings: settings)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Збережені дані")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        loadData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(settings.selectedTheme.primaryColor)
                            .font(.system(size: settings.fontSize.bodySize))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрити") {
                        dismiss()
                    }
                    .foregroundColor(settings.selectedTheme.primaryColor)
                    .font(.system(size: settings.fontSize.bodySize))
                    .bold()
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Завантажуємо дані з файлу (без перевірки часу)
            if let loadedData = FileManagerService.shared.loadCoinsWithoutTimeCheck() {
                DispatchQueue.main.async {
                    savedCoins = loadedData.coins
                    savedDate = loadedData.savedDate
                    isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Файл з даними не знайдено або пошкоджений"
                    isLoading = false
                }
            }
            
            // Отримуємо розмір файлу
            if let info = FileManagerService.shared.getFileInfo() {
                let lines = info.split(separator: "\n")
                if let sizeLine = lines.first(where: { $0.contains("Розмір:") }) {
                    let size = String(sizeLine.split(separator: ":")[1]).trimmingCharacters(in: .whitespaces)
                    DispatchQueue.main.async {
                        fileSize = size
                    }
                }
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date)
    }
    
    func timeAgo(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return days == 1 ? "1 день тому" : "\(days) днів тому"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 годину тому" : "\(hours) годин тому"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 хвилину тому" : "\(minutes) хвилин тому"
        } else {
            return "щойно"
        }
    }
}

// Окрема карточка для відображення криптовалюти
struct CoinCardView: View {
    let coin: CoinItem
    let settings: AppSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Назва та ціна
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.name)
                        .font(.system(size: settings.fontSize.headlineSize))
                        .bold()
                        .foregroundColor(settings.isDarkMode ? .white : .primary)
                    
                    Text(coin.id.uppercased())
                        .font(.system(size: settings.fontSize.captionSize))
                        .foregroundColor(settings.isDarkMode ? .white.opacity(0.6) : .secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", coin.price))")
                        .font(.system(size: settings.fontSize.headlineSize))
                        .bold()
                        .foregroundColor(settings.selectedTheme.primaryColor)
                    
                    Text("USD")
                        .font(.system(size: settings.fontSize.captionSize))
                        .foregroundColor(settings.isDarkMode ? .white.opacity(0.6) : .secondary)
                }
            }
            
            Divider()
                .background(settings.isDarkMode ? .white.opacity(0.2) : .gray.opacity(0.2))
            
            // Детальна інформація
            VStack(spacing: 8) {
                InfoRow(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Ринкова капіталізація",
                    value: NumberFormatter.formatNumber(coin.marketCap),
                    settings: settings
                )
                
                InfoRow(
                    icon: "arrow.up.circle.fill",
                    label: "Максимум за 24h",
                    value: "$\(String(format: "%.2f", coin.high24h))",
                    settings: settings,
                    valueColor: .green
                )
                
                InfoRow(
                    icon: "arrow.down.circle.fill",
                    label: "Мінімум за 24h",
                    value: "$\(String(format: "%.2f", coin.low24h))",
                    settings: settings,
                    valueColor: .red
                )
            }
        }
        .padding()
        .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// Компонент для рядка інформації
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    let settings: AppSettings
    var valueColor: Color?
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(valueColor ?? settings.selectedTheme.primaryColor)
                .font(.system(size: settings.fontSize.bodySize))
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: settings.fontSize.bodySize))
                .foregroundColor(settings.isDarkMode ? .white.opacity(0.8) : .secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: settings.fontSize.bodySize))
                .bold()
                .foregroundColor(valueColor ?? (settings.isDarkMode ? .white : .primary))
        }
    }
}
