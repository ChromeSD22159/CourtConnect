//
//  AbsenseCard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftUI

struct AbsenseCard: View {
    @Binding var isAbsenseSheet: Bool
    @Binding var absenseDate: Date
    let onComplete: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: "circle.badge.minus")
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("Absence report!")
                    .font(.headline)
                Text("Find out your trainer and your team very much about your absence.")
            }
            
            Spacer()
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
        .sheet(isPresented: $isAbsenseSheet, content: {
            NavigationStack {
                VStack {
                    DatePicker("Absense Date", selection: $absenseDate, displayedComponents: .date)
                    
                    Button("Eintragen") {
                        
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isAbsenseSheet.toggle()
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
            isAbsenseSheet.toggle()
        }
    }
}
