//
//  ApiClient.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Foundation

struct ApiClient {  
    static func isPingTest() async throws -> Bool {
        let url = URL(string: "https://google.de")!
        
        let (_, response) = try await URLSession.shared.data(from: url)
        
        return response.isRequestSuccessful()
    }
}

extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
    
    func isRequestSuccessful() -> Bool {
         if let statusCode = getStatusCode() {
             return (200...299).contains(statusCode)
        } else {
            return false
        }
         
    }
}
