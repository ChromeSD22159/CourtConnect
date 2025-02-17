//
//  NetworkMonitorViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//
import SwiftUI
import Network

@Observable
class NetworkMonitorViewModel: ObservableObject {
    
    static let shared = NetworkMonitorViewModel()
    
    var monitor: NWPathMonitor = NWPathMonitor()
    var queue: DispatchQueue = DispatchQueue(label: "Monitor")
    var isConnected = false
    
    init() {
        checkConnection()
    }
    
    func checkConnection() { 
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isConnected = true
            } else {
                self.isConnected = false
            }
        }
    }
    
    private func isPingTest(complete:  @escaping (Bool) -> Void) async { 
        let request = URLRequest(url: URL(string: "8.8.8.8")!)
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            complete(error == nil)
        }.resume()
    } 
} 

struct NetworkMonitorKey: EnvironmentKey {
    static let defaultValue: NetworkMonitorViewModel = NetworkMonitorViewModel.shared
}

extension EnvironmentValues {
    var networkMonitor: NetworkMonitorViewModel {
        get { self[NetworkMonitorKey.self] }
        set { self[NetworkMonitorKey.self] = newValue }
    }
} 
