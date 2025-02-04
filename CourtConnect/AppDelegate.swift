//
//  AppDelegate.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import WishKit

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let infoDict = Bundle.main.infoDictionary, let wishKit = infoDict["WishKit"] as? String {
            WishKit.configure(with: wishKit)
            wishKitConfig()
        }
        
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
            InAppMessagehandlerViewModel.shared.handleMessage(message: InAppMessage(title: title, body: body))
        } else {
            print("Error: Could not extract title or body from alert dictionary")
        }
    }
    
    func wishKitConfig() {
        // Allow user to undo their vote
        WishKit.config.allowUndoVote = true

        // Shows full description of a feature request in the list.
        WishKit.config.expandDescriptionInList = true

        // Hide comment section
        WishKit.config.commentSection = .hide

        // Position the Add-Button.
        WishKit.config.buttons.addButton.bottomPadding = .large

        // Show the status badge of a feature request (e.g. pending, approved, etc.).
        WishKit.config.statusBadge = .show

        // Hide the segmented control.
        WishKit.config.buttons.segmentedControl.display = .show

        // Remove drop shadow.
        WishKit.config.dropShadow = .hide
    }
    
    func wishKitTheme() {
        // This is for the Add-Button, Segmented Control, and Vote-Button.
        WishKit.theme.primaryColor = Theme.darkOrange

        // Set the secondary color (this is for the cells and text fields).
        WishKit.theme.secondaryColor = .set(light: Theme.darkOrange, dark: Theme.lightOrange)

        // Set the tertiary color (this is for the background).
        WishKit.theme.tertiaryColor = .set(light: Theme.background, dark: Theme.background)

        // Segmented Control (Text color)
        WishKit.config.buttons.segmentedControl.defaultTextColor = .setBoth(to: .white)

        WishKit.config.buttons.segmentedControl.activeTextColor = .setBoth(to: .white)

        // Save Button (Text color)
        WishKit.config.buttons.saveButton.textColor = .set(light: .white, dark: .white)
        
 
        WishKit.config.localization.requested = "Angefragt"
        WishKit.config.localization.description = "Beschreinung" 
    }
} 
