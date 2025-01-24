//
//  CourtConnectApp.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI
import Lottie

@main
struct CourtConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
      
    #if targetEnvironment(simulator)
    init() {
        guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
            print("RocketSim: Failed to load linker framework")
            return
        }
        #warning("RocketSim Connect successfully linked")
    }
    #endif
    @State var isSlashScreen = true
    var body: some Scene {
        WindowGroup {
            AppBackground {
                ZStack {
                    LoginNavigation(repository: Repository(type: .app))
                        .opacity(isSlashScreen ? 0 : 1)
                    
                    SplashScreen(duration: 3.0, isVisible: $isSlashScreen) {
                        isSlashScreen.toggle()
                    }
                }
            }
        }
    }
}  
