//
//  DashboardView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import SwiftUI 

struct DashboardView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var networkMonitorViewModel: NetworkMonitorViewModel
    @State @State var inAppMessagehandler = InAppMessagehandler.shared
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
             
                if !networkMonitorViewModel.isConnected {
                    InternetUnavailableView()
                } else {
                    if let email = userViewModel.user?.email {
                        BodyText(email)
                    } 
                }
                
                Button("Test Notification") {
                    inAppMessagehandler.handleMessage(message: InAppMessage(title: "Neue Nachricht von Frederik", body: "Neue Nachricht von Frederik"))
                }
                
            }
            .navigationTitle("Daskboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "person.fill")
                            .padding(10)
                            .onTapGesture {
                                userViewModel.openEditProfileSheet()
                            }
                    }
                }
            }
            .onAppear {
                userViewModel.onAppDashboardAppear()
            }
        } 
    }
}

#Preview {
    DashboardView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)), networkMonitorViewModel: NetworkMonitorViewModel())
        .messagePopover()
}
