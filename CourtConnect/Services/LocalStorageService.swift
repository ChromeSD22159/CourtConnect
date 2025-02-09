//
//  LocalStorageService.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
// 
import Foundation
import Supabase
import WidgetKit

struct LocalStorageService {
    static var shared = LocalStorageService()
    static var store = UserDefaults(suiteName: "group.CourtConnect")
    
    var userAccountId: String? {
        get {
            LocalStorageService.store?.string(forKey: "userAccountId")
        }
        set {
            LocalStorageService.store?.set(newValue, forKey: "userAccountId")
            LocalStorageService.store?.synchronize()
        }
    }
    
    var user: User? {
        get {
            guard let data = LocalStorageService.store?.data(forKey: "SupabaseUser") else { return nil }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
           if let newValue = newValue {
               let data = try? JSONEncoder().encode(newValue)
               LocalStorageService.store?.set(data, forKey: "SupabaseUser")
               WidgetCenter.shared.reloadAllTimelines()
           } else {
               LocalStorageService.store?.removeObject(forKey: "SupabaseUser")
               LocalStorageService.store?.synchronize()
           }
        }
    }
}
