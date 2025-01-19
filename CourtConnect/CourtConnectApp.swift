//
//  CourtConnectApp.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI
import SwiftData
import FirebaseCore
@main
struct CourtConnectApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    let repository: Repository = Repository(type: .app)
    var body: some Scene {
        WindowGroup {
           LoginNavigation(repository: repository)
        }
    } 
}
