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
             
                if !networkMonitorViewModel.isConnected {
                    InternetUnavailableView()
                } else {
                    if let email = userViewModel.user?.email {
                        BodyText(email)
                    }
                    
                    SendNotificationToDevice()
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
 
private struct SendNotificationToDevice: View {
    @State var token = ""
    @State var titelText = "Ich bin der Title"
    @State var bodyText = "Dies ist eine Testnachricht"
    var body: some View {
        Form {
            TextField("", text: $token, prompt: Text("DeviceToken"))
                .textFieldStyle(.roundedBorder)
            
            TextField("", text: $titelText)
                .textFieldStyle(.roundedBorder)
            
            TextField("", text: $bodyText)
                .textFieldStyle(.roundedBorder)
            
            Button("Send", role: .destructive) {
                do {
                    try ApnsMessaging.sendAPNsNotification(deviceToken: token, title: titelText, body: bodyText, completion: {_ in
                        
                    })
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.onAppear {
            if let token = ApnsMessaging.shared.apnsToken {
                self.token = token
            }
        }
    }
}

#Preview {
    DashboardView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)), networkMonitorViewModel: NetworkMonitorViewModel())
}
