//
//  ReviewHandler.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.02.25.
//
import Foundation
import StoreKit

class ReviewHandler {
    static func requestReview() {
        var count = LocalStorageService.shared.appStartUpsCount
        count += 1
        LocalStorageService.shared.appStartUpsCount = count
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            fatalError("Expected to find a bundle version in the info dictionary")
        } 

        let lastVersionPromptedForReview = LocalStorageService.shared.lastVersionPromptedForReview
        
        if count >= 4 && currentVersion != lastVersionPromptedForReview {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                   if #available(iOS 18, *) {
                       AppStore.requestReview(in: scene)
                       LocalStorageService.shared.lastVersionPromptedForReview = currentVersion
                   } else {
                       SKStoreReviewController.requestReview(in: scene)
                       LocalStorageService.shared.lastVersionPromptedForReview = currentVersion
                   }
               }
            }
        }
    }
    
    static func requestReviewManually() {
          let url = "https://apps.apple.com/app/id6741483056?action=write-review"
          guard let writeReviewURL = URL(string: url) else { fatalError("Expected a valid URL") }
          UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
}
