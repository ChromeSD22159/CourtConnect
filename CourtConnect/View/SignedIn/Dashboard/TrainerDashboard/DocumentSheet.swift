//
//  DocumentSheet.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI
import PhotosUI 
 
struct DocumentSheet: View {
    @State var viewModel: DocumentSheetButtonViewModel = DocumentSheetButtonViewModel()
    @Environment(\.dismiss) var dismiss
    var body: some View {
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
                
                TextField("Description", text: $viewModel.description, prompt: Text("Briefly describe the document's content"))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .opacity(viewModel.uiImage != nil ? 1.0 : 0.0)
                    .animation(.easeInOut, value: viewModel.uiImage)
                    .padding(.bottom, 30)
                
                Button("Upload Document") {
                    Task {
                        do {
                            try await viewModel.saveDocuemtThrows()
                            dismiss()
                        } catch {
                            ErrorHandlerViewModel.shared.handleError(error: error)
                        }
                    }
                   
                }
                .errorAlert()
                .disabled(viewModel.image == nil)
                .opacity(viewModel.image == nil ? 0.5 : 1.0)
                .buttonStyle(DarkButtonStlye())
            }
        }
        .onDisappear(perform: viewModel.disappear)
    }
}

#Preview("Add Document") {
    @Previewable @State var isSheet = true
    Button("OPEN") {
        isSheet.toggle()
    }
    .sheet(isPresented: $isSheet, content: {
        DocumentSheet()
    })
}
