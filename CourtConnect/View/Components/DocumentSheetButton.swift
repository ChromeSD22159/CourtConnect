//
//  DocumentSheetButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI
import PhotosUI 

struct DocumentSheetButton: View {
    @State var viewModel: DocumentSheetButtonViewModel
    
    init(userAccount: UserAccount) {
        self.viewModel = DocumentSheetButtonViewModel(userAccount: userAccount)
    }
    
    var body: some View {
        HStack {
            Label("Add Document", systemImage: "text.document")
            Spacer()
        }
        .onTapGesture {
            viewModel.isSheet.toggle()
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
        .sheet(isPresented: $viewModel.isSheet, onDismiss: {}) {
            SheetStlye(title: "Add Document", isLoading: $viewModel.isLoading) {
                VStack(spacing: 20) {
                     
                    if let image = viewModel.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 400, height: 400)
                            .clipped()
                    } else {
                        Image(.basketballPlayer)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 400, height: 400)
                            .clipped()
                    }
                    
                    PhotosPicker(selection: $viewModel.item) {
                        Label(viewModel.item == nil ? "Choose Document" : "Change Document", systemImage: "text.page.badge.magnifyingglass")
                            .padding()
                            .foregroundStyle(.white)
                            .background(Theme.darkOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .padding(.bottom, 30)
                    .onChange(of: viewModel.item) {
                        viewModel.setImage()
                    }
                    
                    Button("Upload Document") {
                        viewModel.saveDocuemt()
                    }
                    .disabled(viewModel.image == nil)
                    .opacity(viewModel.image == nil ? 0.5 : 1.0)
                    .buttonStyle(DarkButtonStlye())
                }
            }
        }
    }
}

struct SheetStlye<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    @Binding var isLoading: Bool
    @ViewBuilder let content: () -> Content
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    content()
                }
                .blur(radius: isLoading ? 2 : 0)
                .animation(.easeIn, value: isLoading)
                
                LoadingCard(isLoading: $isLoading)
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(title)
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
    }
}

#Preview("Add Document") {
    let mockAccount = MockUser.myUserAccount
    NavigationStack {
        DocumentSheetButton(userAccount: mockAccount)
    }
    .navigationStackTint()
} 
