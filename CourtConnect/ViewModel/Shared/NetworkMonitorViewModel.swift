//
//  NetworkMonitorViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//
import SwiftUI
import Network

@Observable
class NetworkMonitorViewModel: ObservableObject, @unchecked Sendable {
    
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
    
    func isPingTest() { 
        Task {
            do {
                self.isConnected =  try await ApiClient.isPingTest()
            } catch {
                print(error.localizedDescription)
            }
        }
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
