import SwiftUI
import Network

// Модель моніторингу мережі
class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue.global()
    
    @Published var isConnected: Bool = true
    
    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

struct CoinItem: Identifiable {
    let id: String
    let name: String
    let price: Double
    let marketCap: Double
    let high24h: Double
    let low24h: Double
}

struct ContentView: View {
    @State private var coins: [CoinItem] = []
    @State private var selectedCoinID: String? = nil
    @State private var infoText: String = "Обери валюту та натисни кнопку"
    @State private var timer: Timer?
    @State private var isRefreshDisabled = false
    @State private var showAlert = false
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.15),
                    Color.purple.opacity(0.15),
                    Color.pink.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
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
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.top)
                
                if coins.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        
                        Text("Завантаження даних...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Оберіть криптовалюту")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Picker("Оберіть валюту", selection: $selectedCoinID) {
                            ForEach(coins) { coin in
                                HStack {
                                    Text(coin.name)
                                    Spacer()
                                    Text("$\(coin.price, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(coin.id as String?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        showInfo()
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.headline)
                            Text("Показати інформацію")
                                .font(.headline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        Text(infoText)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                Button(action: {
                    if !isRefreshDisabled {
                        refreshTimer()
                        loadData()
                    }
                }) {
                    HStack {
                        Image(systemName: isRefreshDisabled ? "clock.fill" : "arrow.clockwise")
                            .font(.headline)
                        Text("Оновити")
                            .font(.headline)
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
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadData()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Помилка з'єднання"),
                message: Text("Немає підключення до Інтернету. Перевірте мережу."),
                dismissButton: .default(Text("ОК"))
            )
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
            
            Ринкова капіталізація: $\(formatNumber(coin.marketCap))
            
            Найвища ціна за 24h: $\(String(format: "%.2f", coin.high24h))
            
            Найнижча ціна за 24h: $\(String(format: "%.2f", coin.low24h))
            """
        } else {
            infoText = "Спочатку оберіть валюту"
        }
    }
    
    func formatNumber(_ number: Double) -> String {
        if number >= 1_000_000_000 {
            return String(format: "%.2f B", number / 1_000_000_000)
        } else if number >= 1_000_000 {
            return String(format: "%.2f M", number / 1_000_000)
        } else {
            return String(format: "%.0f", number)
        }
    }

    func loadData() {
        // Перевірка інтернету перед запитом
        if !networkMonitor.isConnected {
            showAlert = true
            return
        }
        
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=bitcoin,ethereum,solana"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    var loadedCoins: [CoinItem] = []
                    
                    for coin in json {
                        if let id = coin["id"] as? String,
                           let name = coin["name"] as? String,
                           let price = coin["current_price"] as? Double,
                           let marketCap = coin["market_cap"] as? Double,
                           let high24h = coin["high_24h"] as? Double,
                           let low24h = coin["low_24h"] as? Double {
                            
                            loadedCoins.append(CoinItem(id: id, name: name, price: price, marketCap: marketCap, high24h: high24h, low24h: low24h))
                        }
                    }
                    
                    DispatchQueue.main.async {
                        coins = loadedCoins
                        selectedCoinID = loadedCoins.first?.id
                        infoText = "Дані оновлено. Оберіть валюту та натисніть 'Показати інформацію'."
                    }
                } else {
                    DispatchQueue.main.async {
                        infoText = "Помилка при розборі JSON"
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    infoText = "Помилка: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
