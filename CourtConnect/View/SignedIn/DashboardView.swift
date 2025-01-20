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
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let email = userViewModel.user?.email {
                    BodyText(email)
                }
                
                Button {
                    Task {
                        await networkMonitorViewModel.checkConnection()
                    }
                } label: {
                    Image(systemName: networkMonitorViewModel.isConnected ? "wifi" : "wifi.exclamationmark")
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
                        
                        Image(systemName: "rectangle.portrait.and.arrow.right")
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
}
