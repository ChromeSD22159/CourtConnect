//
//  LocalStorageService.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
// 
import Foundation
import Supabase
import WidgetKit
 
struct UserDefaultsKeys {
    static let appStartUpsCountKey = "appStartUpsCountKey"
    static let lastVersionPromptedForReviewKey = "lastVersionPromptedForReviewKey"
    static let userAccountId = "userAccountId"
    static let widgetStatistic = "widgetStatistic"
}

struct LocalStorageService {
    static var shared = LocalStorageService()
    static var store = UserDefaults(suiteName: "group.CourtConnect")
    
    var userAccountId: String? {
        get {
            LocalStorageService.store?.string(forKey: UserDefaultsKeys.userAccountId)
        }
        set {
            LocalStorageService.store?.set(newValue, forKey: UserDefaultsKeys.userAccountId)
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
    
    var appStartUpsCount: Int {
        get {
            UserDefaults.standard.integer(forKey: UserDefaultsKeys.appStartUpsCountKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.appStartUpsCountKey)
        }
    }
    
    var lastVersionPromptedForReview: String? {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
        }
    }
    
    var widgetStatistic: WidgetStatistic? {
        get {
            guard let data = LocalStorageService.store?.data(forKey: UserDefaultsKeys.widgetStatistic) else { return nil }
            return try? JSONDecoder().decode(WidgetStatistic.self, from: data)
        }
        set {
           if let newValue = newValue {
               let data = try? JSONEncoder().encode(newValue)
               LocalStorageService.store?.set(data, forKey: UserDefaultsKeys.widgetStatistic)
               WidgetCenter.shared.reloadAllTimelines()
           } else {
               LocalStorageService.store?.removeObject(forKey: UserDefaultsKeys.widgetStatistic)
               LocalStorageService.store?.synchronize()
           }
        }
    }
}
