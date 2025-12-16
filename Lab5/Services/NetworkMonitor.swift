import Foundation
import Network

class NetworkMonitor {
    static func isInternetAvailable() -> Bool {
        let monitor = NWPathMonitor()
        let semaphore = DispatchSemaphore(value: 0)
        var status = false
        
        monitor.pathUpdateHandler = { path in
            status = (path.status == .satisfied)
            semaphore.signal()
            monitor.cancel()
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        _ = semaphore.wait(timeout: .now() + 1.0)
        
        return status
    }
}
