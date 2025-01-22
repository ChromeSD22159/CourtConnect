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
    @State var inAppMessagehandler = InAppMessagehandler.shared
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if !networkMonitorViewModel.isConnected {
                    InternetUnavailableView()
                } else {
                    EmptyView()
                }
            } 
            .navigationTitle("Daskboard")
            .navigationBarTitleDisplayMode(.inline)
            .userToolBar(userViewModel: userViewModel)
            .onAppear {
                userViewModel.onAppDashboardAppear()
            }
        } 
    }
}
 
#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: Repository(type: .preview))
    @Previewable @State var networkMonitorViewModel = NetworkMonitorViewModel()
    DashboardView(
        userViewModel: userViewModel,
        networkMonitorViewModel: networkMonitorViewModel
    ) 
    .messagePopover()
}
