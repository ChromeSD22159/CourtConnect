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
}
