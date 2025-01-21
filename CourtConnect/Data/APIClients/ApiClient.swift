//
//  ApiClient.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Foundation

struct ApiClient {
    static let host = TokenService.supabaseHost
    static let key = TokenService.supabaseHost
    static func login(email: String, password: String) {
        let url =  URL(string: host + "/auth/v1/sign_in")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("email", forHTTPHeaderField: email)
        request.setValue("password", forHTTPHeaderField: password)
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("HTTP Request Failed \(error)")
            } else if let response = response {
                _ = response.getStatusCode()
            }
        }

        task.resume()
    }
    
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
