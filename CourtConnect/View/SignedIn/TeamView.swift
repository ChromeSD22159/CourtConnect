//
//  TeamView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI
 
struct TeamView: View {
    @Environment(\.messagehandler) var messagehandler
    let teamJoinCode = "123456"
    var body: some View {
        VStack {
          //
        }
        .navigationTitle("TeamName")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Text("TeamName")
                    Button {
                        ClipboardHelper.copy(text: teamJoinCode)
                        
                        messagehandler.handleMessage(message: InAppMessage(title: "TeamId Kopiert"))
                    } label: {
                        Label("Copy Team ID", systemImage: "arrow.right.doc.on.clipboard")
                    }
                    ShareLink(item: "TeamID: \(teamJoinCode)")
                } label: {
                    Image(systemName: "figure")
                        .foregroundStyle(Theme.lightOrange)
                }

            }
        }
    }
}

#Preview {
    NavigationStack {
        MessagePopover {
            TeamView()
        }
    }
}
