//
//  ManageDocumentsView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 15.02.25.
//
import SwiftUI
import Auth

struct ManageDocumentsView: View {
    @State var viewModel = ManageDocumentsViewModel()
    var body: some View {
        AnimationBackgroundChange {
            List {
                if viewModel.documents.isEmpty {
                    Section {
                        ContentUnavailableView("No documents found", systemImage: "text.document", description: Text("Your team has no documents."))
                    }.blurrylistRowBackground()
                } else {
                    Section {
                        ForEach(viewModel.documents) { document in
                            let createDateString = document.createdAt.formattedDate().stringValue() ?? ""
                            let createDateTime = document.createdAt.formattedTime().stringValue() ?? ""
                            let updatedDateString =  document.updatedAt.formattedDate().stringValue() ?? ""
                            let documentDateTime = document.updatedAt.formattedTime().stringValue() ?? ""
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    AsyncCachedImage(url: URL(string: document.url)!) { image in
                                        image
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                    } placeholder: {
                                        ZStack {
                                            Image(systemName: "doc")
                                                .font(.largeTitle)
                                                .padding(20)
                                        }
                                    }
                                    
                                    VStack {
                                        Text(document.name)
                                            .font(.headline)
                                        
                                        Text(document.info)
                                    }
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Text("created: \(createDateString) - \(createDateTime)")
                                    
                                    Spacer()
                                    
                                    Text("updated: \(updatedDateString) - \(documentDateTime)")
                                }.font(.caption)
                            }
                            .onTapGesture {
                                viewModel.edit(document: document)
                            }
                            .padding(.vertical, 10)
                            .swipeActions {
                                Button {
                                    viewModel.delete(document: document)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                
                                Button {
                                    viewModel.edit(document: document)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Theme.lightOrange)
                            }
                        }
                    }.blurrylistRowBackground()
                }
            }
            .sheet(item: $viewModel.selectedDocument) { document in
                EditDocumentSheet(document: document) { newDocument in
                    viewModel.saveDocument(document: newDocument)
                }
            }
        }
        .navigationTitle(title: "Manage Documents")
        .listBackgroundAnimated()
    }
} 

struct EditDocumentSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var name = ""
    
    var document: Document
    let complete: (Document) -> Void
     
    var body: some View {
        SheetStlye(title: "Edit Document", detents: [.medium, .large], isLoading: .constant(false)) {
            VStack {
                AsyncCachedImage(url: URL(string: document.url)!) { image in
                    image
                        .resizable()
                        .frame(width: 300, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                } placeholder: {
                    ZStack {
                        Image(systemName: "doc")
                            .font(.largeTitle)
                            .padding(20)
                    }
                }
                
                TextField("Filename", text: $name, prompt: Text("Document name e.g. Instruction"))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                 
                Button("Edit Document") {
                    Task {
                        document.name = name
                        complete(document)
                        dismiss()
                    }
                }
                .errorAlert()
                .disabled(document.name == name)
                .opacity(document.name == name ? 0.5 : 1.0)
                .buttonStyle(DarkButtonStlye())
            }
            .padding(.bottom)
        }
        .onAppear {
            name = document.name
        }
    }
}
