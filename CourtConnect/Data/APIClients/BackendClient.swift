//
//  BackendClient.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Supabase
import Foundation

struct BackendClient {
    static var shared = BackendClient()
    
    let supabaseURL: String
    let supabaseKey: String
    
    init() {
        do {
            self.supabaseURL = Bundle.main.infoDictionary?["SupabaseUrl"] as! String as String
            self.supabaseKey = Bundle.main.infoDictionary?["SupabaseKey"] as! String as String
            
            if supabaseURL.isEmpty && supabaseURL.isEmpty {
                throw UserError.userIdNotFound
            }
        } catch {
            fatalError("No Backend Url or Key")
        }
    }
    
    var supabase: SupabaseClient {
        SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }
}
