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
        RowLabelButton(text: "Add Document", systemImage: "text.document", material: .ultraThinMaterial) {
            viewModel.isSheet.toggle()
        }
        .sheet(isPresented: $viewModel.isSheet, onDismiss: {}) {
            SheetStlye(title: "Add Document", detents: [.large], isLoading: $viewModel.isLoading) {
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
                    .onChange(of: viewModel.item) {
                        viewModel.setImage()
                    }
                    
                    TextField("Filename", text: $viewModel.fileName, prompt: Text("Document name e.g. Instruction"))
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .opacity(viewModel.uiImage != nil ? 1.0 : 0.0)
                        .animation(.easeInOut, value: viewModel.uiImage)
                        .padding(.bottom, 30)
                    
                    Button("Upload Document") {
                        viewModel.saveDocuemt()
                    }
                    .disabled(viewModel.image == nil)
                    .opacity(viewModel.image == nil ? 0.5 : 1.0)
                    .buttonStyle(DarkButtonStlye())
                }
            }
            .onDisappear(perform: viewModel.disappear)
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
