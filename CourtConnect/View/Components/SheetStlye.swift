//
//  SheetStlye.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI

struct SheetStlye<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    let title: LocalizedStringKey
    let detents: Set<PresentationDetent> 
    @Binding var isLoading: Bool
    @ViewBuilder let content: () -> Content
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    content()
                }
                .scrollIndicators(.hidden)
                .contentMargins(.top, 10)
                .blur(radius: isLoading ? 2 : 0)
                .animation(.easeIn, value: isLoading)
                
                LoadingCard(isLoading: $isLoading)
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(title.stringValue()?.uppercased() ?? "")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Theme.darkOrange,
                                    Theme.lightOrange
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "xmark")
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
        }
        .presentationBackground(Material.ultraThinMaterial)
        .presentationDetents(detents)
        .presentationCornerRadius(25)
    }
}

#Preview {
    ZStack {}
    .sheet(isPresented: .constant(true)) {
        SheetStlye(title: "Title", detents: [.medium], isLoading: .constant(false)) {
            VStack {
                Text("asdsad")
            }
        }
    }
}
