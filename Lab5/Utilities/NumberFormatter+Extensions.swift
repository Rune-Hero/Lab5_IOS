import Foundation

extension NumberFormatter {
    static func formatNumber(_ number: Double) -> String {
        if number >= 1_000_000_000 {
            return String(format: "%.2f B", number / 1_000_000_000)
        } else if number >= 1_000_000 {
            return String(format: "%.2f M", number / 1_000_000)
        } else {
            return String(format: "%.0f", number)
        }
    }
}
