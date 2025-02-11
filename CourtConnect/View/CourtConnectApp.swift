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
    @Environment(\.scenePhase) var scenePhase
    @State var authViewModel: AuthViewModel = AuthViewModel()
       
    var body: some Scene {
        WindowGroup {
            AppBackground {
                ZStack {
                    Group {
                        if authViewModel.user != nil && authViewModel.isSlashScreen == false {
                            MainNavigationView(authViewModel: authViewModel) {
                                authViewModel.user = nil
                            }
                        } else {
                            LoginEntryView {
                                authViewModel.inizializeAuth()
                                authViewModel.getAccounts()
                            }
                        }
                    }
                    .opacity(authViewModel.isSlashScreen ? 0 : 1)
                    
                    SplashScreen(isVisible: $authViewModel.isSlashScreen, duration: 1.5, userId: authViewModel.user?.id, onStart: {
                        authViewModel.getAccounts()
                    }, onComplete: {
                        authViewModel.isSlashScreen.toggle()
                    })
                }
            }
            .onAppear {
                authViewModel.loadRocketSimConnect()
                authViewModel.getAccounts()
            }
            .onChange(of: scenePhase, {
                authViewModel.onScenePhaseChange(newValue: scenePhase)
            })
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
