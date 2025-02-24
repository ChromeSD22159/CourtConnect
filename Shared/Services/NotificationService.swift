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
    
    static func request() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) 
        } catch {
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
    
    static func loadAllLocalNotifications() async -> [UNNotificationRequest] {
            await UNUserNotificationCenter.current().pendingNotificationRequests()
        }

        static func findNotification(id: UUID) async -> UNNotificationRequest? {
            let requests = await loadAllLocalNotifications()
            return requests.first { $0.identifier == id.uuidString }
        }
    
    static func setNotification(for note: Note) throws {
        let content = UNMutableNotificationContent()
        content.title = "Note Reminder"
        content.body = note.title
        content.sound = .default

        let identifier = note.id.uuidString

        let targetDate = note.date
 
        let timeInterval = targetDate.timeIntervalSinceNow
 
        guard timeInterval > 0 else { throw NotificationError.pastDate }
 
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        Task {
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("Notification scheduled for note: \(note.id) at \(targetDate)")
            } catch {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    static func deleteNotification(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        print("Notification deleted for note: \(id)")
    }
} 
