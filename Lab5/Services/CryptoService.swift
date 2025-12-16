import Foundation

class CryptoService {
    static func fetchCoins(completion: @escaping (Result<[CoinItem], Error>) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=bitcoin,ethereum,solana"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    var loadedCoins: [CoinItem] = []
                    
                    for coin in json {
                        if let id = coin["id"] as? String,
                           let name = coin["name"] as? String,
                           let price = coin["current_price"] as? Double,
                           let marketCap = coin["market_cap"] as? Double,
                           let high24h = coin["high_24h"] as? Double,
                           let low24h = coin["low_24h"] as? Double {
                            
                            loadedCoins.append(CoinItem(
                                id: id,
                                name: name,
                                price: price,
                                marketCap: marketCap,
                                high24h: high24h,
                                low24h: low24h
                            ))
                        }
                    }
                    
                    completion(.success(loadedCoins))
                } else {
                    completion(.failure(NSError(domain: "JSON parsing error", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
