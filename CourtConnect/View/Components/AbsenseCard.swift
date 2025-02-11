//
//  AbsenseCard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftUI

struct AbsenseCard: View {
    @Bindable var playerDashboardViewModel: PlayerDashboardViewModel
    let onComplete: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: "circle.badge.minus")
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("Prevents or sick?!")
                    .font(.headline)
                Text("Register your absence to the coaching team.")
            }
            
            Spacer()
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15)) 
        .sheet(isPresented: $playerDashboardViewModel.isAbsenseSheet, content: {
            NavigationStack {
                VStack {
                    DatePicker("Absense Date", selection: $playerDashboardViewModel.absenseDate, displayedComponents: .date)
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            playerDashboardViewModel.isAbsenseSheet.toggle()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Send") {
                            onComplete()
                        }
                    }
                }
                .navigationTitle("Absense")
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationStackTint()
            .presentationDetents([.height(150)])
            .presentationBackground(Material.ultraThinMaterial)
            .presentationCornerRadius(20)
        })
        .onTapGesture {
            playerDashboardViewModel.isAbsenseSheet.toggle()
        }
    }
}
