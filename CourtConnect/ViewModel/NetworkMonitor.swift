//
//  NetworkMonitor.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//
import SwiftUI

@Observable
class NetworkMonitorViewModel: ObservableObject {
    var isConnected = false

    init() {
        Task {
            await checkConnection()
        }
    }
    
    func checkConnection() async {
        await self.isPingTest { result in
            self.isConnected = result
        }
    }
    
    private func isPingTest(complete:  @escaping (Bool) -> Void) async {
        let request = URLRequest(url: URL(string: "https://google.de")!)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            complete(error == nil)
        }.resume()
    }
    
   
}
