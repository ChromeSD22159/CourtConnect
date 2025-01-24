//
//  LocalStorageService.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
// 
import Foundation

struct LocalStorageService {
    static var shared = LocalStorageService()
    
    var userAccountId: String? {
        get {
            UserDefaults.standard.string(forKey: "userAccountId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userAccountId")
        }
    }
    
    var user: SupabaseUser? {
        get {
           guard let data = UserDefaults.standard.data(forKey: "SupabaseUser") else { return nil }
           return try? JSONDecoder().decode(SupabaseUser.self, from: data)
        }
        set {
           if let newValue = newValue {
               let data = try? JSONEncoder().encode(newValue)
               UserDefaults.standard.set(data, forKey: "SupabaseUser")
           } else {
               UserDefaults.standard.removeObject(forKey: "SupabaseUser")
           }
        }
    }
}
