//
//  CourtConnectApp.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI

@main
struct CourtConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    #if targetEnvironment(simulator)
    init() {
        
        guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
            print("RocketSim: Failed to load linker framework")
            return
        }
        print("RocketSim Connect successfully linked")
        
    }
    #endif
    
    var body: some Scene {
        WindowGroup {
            LoginNavigation(repository: Repository(type: .app)) 
        }
    }
}
