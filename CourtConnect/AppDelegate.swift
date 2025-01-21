//
//  AppDelegate.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//

import UIKit
import FirebaseCore
import FirebaseMessaging 

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        UIApplication.shared.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        ApnsMessaging.shared.apnsToken = deviceTokenString
         
        // FIREBASE FCM
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Try again later.
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = Messaging.messaging().fcmToken {
            print("fcmToken: \(fcmToken)")
        }
    }
} 
