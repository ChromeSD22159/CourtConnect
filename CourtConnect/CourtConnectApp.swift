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
     
    @State var userViewModel: SharedUserViewModel = SharedUserViewModel(repository: Repository.shared)
    
    init() {
        let repo = Repository.shared
        userViewModel = SharedUserViewModel(repository: repo)
          
        loadRocketSimConnect()
    }
     
    @State var isSlashScreen = true
    @State var show = false
    var body: some Scene {
        WindowGroup {
            AppBackground {
                ZStack {
                    Group {
                        if userViewModel.user != nil {
                            MainNavigationView(userViewModel: userViewModel)
                        } else {
                            LoginEntryView(userViewModel: userViewModel)
                        }
                    }
                    .opacity(isSlashScreen ? 0 : 1)
                    
                    SplashScreen(isVisible: $isSlashScreen, duration: 1.5, userId: userViewModel.user?.id, onStart: {
                        Task {
                            await userViewModel.isAuthendicated()
                        }
                    }, onComplete: {
                        isSlashScreen.toggle() 
                    })
                }
            }
        }
    }
} 

extension View {
    func previewEnvirments() -> some View {
        modifier(PreviewEnvirments())
    }
}

struct PreviewEnvirments: ViewModifier {
    @State var errorHandlerViewModel = ErrorHandlerViewModel.shared
    @State var inAppMessagehandlerViewModel = InAppMessagehandlerViewModel.shared
    let repo = RepositoryPreview.shared
    func body(content: Content) -> some View {
        content  
            .environment(\.messagehandler, InAppMessagehandlerViewModel())
            .environment(\.networkMonitor, NetworkMonitorViewModel())
            .environment(\.errorHandler, errorHandlerViewModel)
            .errorPopover()
            .messagePopover()
    }
}
   
private func loadRocketSimConnect() {
    #warning("RocketSim Connect successfully linked")
    #if DEBUG
    guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
        print("Failed to load linker framework")
        return
    }
    print("RocketSim Connect successfully linked")
    #endif
}
