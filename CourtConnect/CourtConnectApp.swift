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
      
    let repository: Repository
    @State var syncServiceViewModel: SyncServiceViewModel
    @State var userViewModel: SharedUserViewModel
    
    init() {
        repository = Repository(type: .app)
        userViewModel = SharedUserViewModel(repository: repository)
        syncServiceViewModel = SyncServiceViewModel(repository: repository)
        
        #if targetEnvironment(simulator)
        guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
            print("RocketSim: Failed to load linker framework")
            return
        }
        #warning("RocketSim Connect successfully linked")
        #endif
    }
     
    @State var isSlashScreen = true
    
    var body: some Scene {
        WindowGroup {
            AppBackground {
                ZStack {
                    LoginNavigation(userViewModel: userViewModel)
                        .opacity(isSlashScreen ? 0 : 1)
                    
                    SplashScreen(isVisible: $isSlashScreen, duration: 1.5, userId: userViewModel.user?.id, onComplete: {
                        isSlashScreen.toggle()
                        
                        if userViewModel.userProfile?.onBoardingAt == nil {
                            userViewModel.showOnBoarding = true
                        }
                    })
                }
            }
            .environment(syncServiceViewModel)
        }
    }
}  
