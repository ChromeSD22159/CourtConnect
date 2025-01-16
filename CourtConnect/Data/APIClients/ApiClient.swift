//
//  ApiClient.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
// 
import Foundation 

struct ApiClient {
    static let host = "https://anwqiuyfuhaebycbblrc.supabase.co"
    static let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFud3FpdXlmdWhhZWJ5Y2JibHJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY2MzY0MTcsImV4cCI6MjA1MjIxMjQxN30.JBCicVin0f56ZLj8BL7YEIMIETVxOF0I_dfbyMtx-R4"
    
    static func login(email:String, password: String) {
        let url =  URL(string: host + "/auth/v1/sign_in")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("email", forHTTPHeaderField: email)
        request.setValue("password", forHTTPHeaderField: password)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = data {
                
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            } else if let response = response {
                let _ = response.getStatusCode()
            }
        }

        task.resume()
    }
}

extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}
