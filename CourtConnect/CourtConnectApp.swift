//
//  CourtConnectApp.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import SwiftUI
import SwiftData

@main
struct CourtConnectApp: App {
    let repository: Repository = Repository(type: .app)
    var body: some Scene {
        WindowGroup {
            LoginNavigation(repository: repository)
        }
    }
} 
