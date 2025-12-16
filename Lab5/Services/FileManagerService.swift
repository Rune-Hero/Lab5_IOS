import Foundation

class FileManagerService {
    static let shared = FileManagerService()
    
    private let fileName = "crypto_data.json"
    
    private init() {}
    
    // Отримати URL файлу в директорії Documents
    private func getFileURL() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Не вдалося отримати директорію Documents")
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    // Зберегти дані криптовалют у файл
    func saveCoins(_ coins: [CoinItem]) -> Bool {
        guard let fileURL = getFileURL() else { return false }
        
        do {
            // Перетворюємо масив CoinItem в масив словників
            let coinsData = coins.map { coin -> [String: Any] in
                return [
                    "id": coin.id,
                    "name": coin.name,
                    "price": coin.price,
                    "marketCap": coin.marketCap,
                    "high24h": coin.high24h,
                    "low24h": coin.low24h
                ]
            }
            
            // Створюємо об'єкт з даними та часом збереження
            let dataToSave: [String: Any] = [
                "coins": coinsData,
                "savedAt": Date().timeIntervalSince1970
            ]
            
            // Серіалізуємо в JSON
            let jsonData = try JSONSerialization.data(withJSONObject: dataToSave, options: .prettyPrinted)
            
            // Записуємо у файл
            try jsonData.write(to: fileURL)
            
            print("Дані успішно збережено в: \(fileURL.path)")
            return true
        } catch {
            print("Помилка при збереженні даних: \(error.localizedDescription)")
            return false
        }
    }
    
    // Завантажити дані криптовалют з файлу (з перевіркою часу - 1 година)
    func loadCoins() -> [CoinItem]? {
        guard let fileURL = getFileURL() else { return nil }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("ℹ️ Файл не існує: \(fileURL.path)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let coinsArray = json["coins"] as? [[String: Any]],
                  let savedAt = json["savedAt"] as? TimeInterval else {
                return nil
            }
            
            let currentTime = Date().timeIntervalSince1970
            let oneHour: TimeInterval = 3600
            
            if currentTime - savedAt > oneHour {
                print("Збережені дані застарілі (старіші за 1 годину)")
                return nil
            }
            
            return parseCoins(from: coinsArray)
        } catch {
            print("Помилка при завантаженні даних: \(error.localizedDescription)")
            return nil
        }
    }
    
    // === НОВИЙ МЕТОД: Завантажити дані без перевірки часу ===
    func loadCoinsWithoutTimeCheck() -> (coins: [CoinItem], savedDate: Date)? {
        guard let fileURL = getFileURL() else { return nil }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let coinsArray = json["coins"] as? [[String: Any]],
                  let savedAt = json["savedAt"] as? TimeInterval else {
                return nil
            }
            
            let savedDate = Date(timeIntervalSince1970: savedAt)
            let coins = parseCoins(from: coinsArray)
            
            return (coins, savedDate)
            
        } catch {
            print("Помилка при зчитуванні даних: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Допоміжний метод для парсингу
    private func parseCoins(from array: [[String: Any]]) -> [CoinItem] {
        var coins: [CoinItem] = []
        for coinDict in array {
            if let id = coinDict["id"] as? String,
               let name = coinDict["name"] as? String,
               let price = coinDict["price"] as? Double,
               let marketCap = coinDict["marketCap"] as? Double,
               let high24h = coinDict["high24h"] as? Double,
               let low24h = coinDict["low24h"] as? Double {
                
                coins.append(CoinItem(
                    id: id,
                    name: name,
                    price: price,
                    marketCap: marketCap,
                    high24h: high24h,
                    low24h: low24h
                ))
            }
        }
        return coins
    }
    
    // Видалити файл з даними
    func deleteCoinsFile() -> Bool {
        guard let fileURL = getFileURL() else { return false }
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return true }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
            print("Помилка видалення: \(error.localizedDescription)")
            return false
        }
    }
    
    // Отримати інформацію про файл
    func getFileInfo() -> String? {
        guard let fileURL = getFileURL() else { return nil }
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return "Файл не існує" }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? UInt64,
               let modificationDate = attributes[.modificationDate] as? Date {
                
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .medium
                formatter.locale = Locale(identifier: "uk_UA")
                let sizeInKB = Double(fileSize) / 1024.0
                
                return """
                Шлях: \(fileURL.path)
                Розмір: \(String(format: "%.2f", sizeInKB)) KB
                Остання зміна: \(formatter.string(from: modificationDate))
                """
            }
        } catch {
            return "Помилка: \(error.localizedDescription)"
        }
        return nil
    }
}
