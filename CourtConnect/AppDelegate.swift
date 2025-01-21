//
//  AppDelegate.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//

import UIKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
          print("Firebase registration token: \(String(describing: fcmToken))")

          let dataDict: [String: String] = ["token": fcmToken ?? ""]
          NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
          )
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo[AnyHashable("aps")] as? [AnyHashable: Any] else {
            print("Error: Could not find aps dictionary in notification data")
            return
        }
        
        guard let alert = aps["alert"] as? [AnyHashable: Any] else {
            print("Error: Could not find alert dictionary in aps dictionary")
            return
        }
        
        if let title = alert["title"] as? String, let body = alert["body"] as? String {
            InAppMessagehandler.shared.handleMessage(message: InAppMessage(title: title, body: body))
        } else {
            print("Error: Could not extract title or body from alert dictionary")
        }
    }
} 
