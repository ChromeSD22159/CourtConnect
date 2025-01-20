//
//  NotificationService.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.01.25.
//

import Observation
import Foundation
import UserNotifications
 
struct NotificationService {
    
    static func request() async{
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) 
        } catch{
            print(error)
        }
    }
    
    static func getAuthStatus() async -> Bool {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            return true
        default:
            return false
        }
    }
}
