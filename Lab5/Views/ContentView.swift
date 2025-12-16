import SwiftUI

struct ContentView: View {
    @StateObject private var settings = AppSettings()
    @State private var coins: [CoinItem] = []
    @State private var selectedCoinID: String? = nil
    @State private var infoText: String = "Обери валюту та натисни кнопку"
    @State private var timer: Timer?
    @State private var isRefreshDisabled = false
    @State private var showAlert = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: settings.isDarkMode ?
                    settings.selectedTheme.darkGradientColors :
                    settings.selectedTheme.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Заголовок та налаштування
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Курси криптовалют")
                            .font(.system(size: settings.fontSize.titleSize))
                            .bold()
                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(settings.selectedTheme.primaryColor)
                            .padding(8)
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
                
                if coins.isEmpty {
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
                    .padding(.horizontal)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Оберіть криптовалюту")
                            .font(.system(size: settings.fontSize.headlineSize))
                            .foregroundColor(settings.isDarkMode ? .white.opacity(0.8) : .secondary)
                        
                        Picker("Оберіть валюту", selection: $selectedCoinID) {
                            ForEach(coins) { coin in
                                if settings.showPriceInPicker {
                                    HStack {
                                        Text(coin.name)
                                            .font(.system(size: settings.fontSize.bodySize))
                                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                                        Spacer()
                                        Text("$\(coin.price, specifier: "%.2f")")
                                            .font(.system(size: settings.fontSize.captionSize))
                                            .foregroundColor(settings.isDarkMode ? .white.opacity(0.7) : .secondary)
                                    }
                                    .tag(coin.id as String?)
                                } else {
                                    Text(coin.name)
                                        .font(.system(size: settings.fontSize.bodySize))
                                        .foregroundColor(settings.isDarkMode ? .white : .primary)
                                        .tag(coin.id as String?)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        showInfo()
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: settings.fontSize.headlineSize))
                            Text("Показати інформацію")
                                .font(.system(size: settings.fontSize.headlineSize))
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [settings.selectedTheme.primaryColor, settings.selectedTheme.primaryColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: settings.selectedTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        Text(infoText)
                            .font(.system(size: settings.fontSize.bodySize))
                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(settings.isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                // Кнопка Оновити (Інтернет)
                Button(action: {
                    if !isRefreshDisabled {
                        if !NetworkMonitor.isInternetAvailable() {
                            showAlert = true
                            return
                        }
                        refreshTimer()
                        loadData()
                    }
                }) {
                    HStack {
                        Image(systemName: isRefreshDisabled ? "clock.fill" : "arrow.clockwise")
                            .font(.system(size: settings.fontSize.headlineSize))
                        Text("Оновити")
                            .font(.system(size: settings.fontSize.headlineSize))
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: isRefreshDisabled ? [.gray, .gray.opacity(0.8)] : [.green, .green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: isRefreshDisabled ? .gray.opacity(0.3) : .green.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .disabled(isRefreshDisabled)
                
                // === КНОПКА: Завантажити з файлу (Offline mode) ===
                Button(action: {
                    loadFromLocalFile()
                }) {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: settings.fontSize.headlineSize))
                        Text("Завантажити з файлу")
                            .font(.system(size: settings.fontSize.headlineSize))
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .indigo.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadDataOnStart()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Помилка з'єднання"),
                message: Text("Немає підключення до Інтернету. Спробуйте завантажити збережені дані з файлу."),
                dismissButton: .default(Text("ОК"))
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings)
        }
    }
    
    func refreshTimer() {
        isRefreshDisabled = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            timer?.invalidate()
            isRefreshDisabled = false
        }
    }
    
    func showInfo() {
        if let selectedID = selectedCoinID,
           let coin = coins.first(where: { $0.id == selectedID }) {
            
            infoText = """
            Назва: \(coin.name)
            
            Ціна: $\(String(format: "%.2f", coin.price)) USD
            
            Ринкова капіталізація: $\(NumberFormatter.formatNumber(coin.marketCap))
            
            Найвища ціна за 24h: $\(String(format: "%.2f", coin.high24h))
            
            Найнижча ціна за 24h: $\(String(format: "%.2f", coin.low24h))
            """
        } else {
            infoText = "Спочатку оберіть валюту"
        }
    }
    
    // Функція для завантаження даних локально (навіть "старих")
    func loadFromLocalFile() {
        if let result = FileManagerService.shared.loadCoinsWithoutTimeCheck() {
            self.coins = result.coins
            
            if selectedCoinID == nil {
                selectedCoinID = result.coins.first?.id
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            let dateStr = formatter.string(from: result.savedDate)
            
            infoText = "Дані успішно відновлено з файлу (збережені \(dateStr)). Оберіть валюту."
        } else {
            infoText = "Локальний файл не знайдено або він порожній."
        }
    }

    func loadData() {
        CryptoService.fetchCoins { result in
            switch result {
            case .success(let loadedCoins):
                DispatchQueue.main.async {
                    coins = loadedCoins
                    selectedCoinID = loadedCoins.first?.id
                    
                    if FileManagerService.shared.saveCoins(loadedCoins) {
                        infoText = "Дані оновлено та збережено. Оберіть валюту та натисніть 'Показати інформацію'."
                    } else {
                        infoText = "Дані оновлено (помилка збереження). Оберіть валюту та натисніть 'Показати інформацію'."
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    infoText = "Помилка: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func loadDataOnStart() {
        if let savedCoins = FileManagerService.shared.loadCoins(), !savedCoins.isEmpty {
            coins = savedCoins
            selectedCoinID = savedCoins.first?.id
            infoText = "Завантажено свіжі збережені дані. Оберіть валюту та натисніть 'Показати інформацію'."
        } else {
            print("Немає збережених свіжих даних, завантажуємо з API...")
            loadData()
        }
    }
}
