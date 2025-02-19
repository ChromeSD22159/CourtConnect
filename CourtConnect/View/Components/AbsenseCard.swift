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
        .borderRadius(15)
        .sheet(isPresented: $playerDashboardViewModel.isAbsenseSheet, content: {
            NavigationStack {
                VStack { 
                    DatePicker("Absense Start Date", selection: $playerDashboardViewModel.startDate, in: playerDashboardViewModel.range, displayedComponents: .date)
                    DatePicker("Absense End Date", selection: $playerDashboardViewModel.endDate, in: playerDashboardViewModel.range, displayedComponents: .date)
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
                .navigationTitle(title: "Absense")
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
