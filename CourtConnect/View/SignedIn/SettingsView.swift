//
//  SettingsViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import Foundation
import Supabase
import SwiftUI

struct SettingsView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let date = userViewModel.userProfile?.lastOnline {
                        HStack {
                            Text("Zuletzt Online:")
                            Spacer()
                            Text(date.formattedDate() + " " + date.formattedTime() + " Uhr")
                        }
                    } else {
                        Text("Zuletzt Online: -")
                    } 
                    
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Version: \(appVersion)")
                    } else {
                        Text("Version: -")
                    }
                } header: {
                    Text("App Status")
                }
                
                Section {
                    Text("Logout")
                        .onTapGesture {
                            userViewModel.signOut()
                        }
                        .foregroundStyle(.white)
                        .listRowBackground(Color.red)
                }
            }
            .navigationTitle("Settings")
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
        }
        
    }
}

extension Date {
    func formattedDate() -> String {
        self.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.twoDigits)
        )
    }
    
    func formattedTime() -> String {
        self.formatted(
            .dateTime
                .hour(.twoDigits(amPM: .narrow))
                .minute(.twoDigits)
        )
    }
}

#Preview {
    SettingsView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)))
}
