//
//  BackendClient.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Supabase
import Foundation

struct BackendClient {
    static let shared = BackendClient()
    
    let supabase: SupabaseClient
    
    private init() {
        guard let config = Self.getSupabaseConfig() else {
            fatalError("No valid Supabase configuration found in Info.plist")
        }
        
        guard let supabaseURL = URL(string: config.url) else {
            fatalError("Invalid Supabase URL: \(config.url)")
        }
        
        self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: config.key)
        
        print("Aktive Umgebung: \(config.name)")
        print("BackendURL: \(config.url)") 
    }
    
    private static func getSupabaseConfig() -> SupabaseConfig? {
        guard let infoDict = Bundle.main.infoDictionary,
              let environments = infoDict["SupabaseEnvironments"] as? [[String: Any]],
              let defaultEnvironment = infoDict["DefaultEnvironment"] as? String else {
            return nil
        }
        
        return environments.first { $0["Name"] as? String == defaultEnvironment }
            .flatMap { environment in
                guard let name = environment["Name"] as? String,
                      let key = environment["SupabaseKey"] as? String,
                      let url = environment["SupabaseUrl"] as? String else { return nil }
                return SupabaseConfig(name: name, key: key, url: url)
            }
    }
    
    struct SupabaseConfig {
        let name: String
        let key: String
        let url: String
    }
}
