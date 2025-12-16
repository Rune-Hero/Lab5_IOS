import Foundation

struct CoinItem: Identifiable {
    let id: String
    let name: String
    let price: Double
    let marketCap: Double
    let high24h: Double
    let low24h: Double
}
