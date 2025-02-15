//
//  ManageDocumentsViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 15.02.25.
//
import Foundation
import Auth

@Observable class ManageDocumentsViewModel: AuthProtocol {
    var repository: BaseRepository = Repository.shared
    
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    var documents: [Document] = []
    
    var selectedDocument: Document?
    
    init() {
        inizializeAuth()
        getAllDocuments()
    }
    
    func getAllDocuments() {
        guard let team = currentTeam else { return }
        do {
            let localDocuments = try repository.documentRepository.getDocuments(for: team.id)
             
            self.documents = localDocuments
        } catch {
            print(error)
        }
    }
    
    func delete(document: Document) {
        Task {
            defer { getAllDocuments() }
            do {
                guard let user = user else { throw UserError.userIdNotFound }
                try await repository.documentRepository.softDelete(document: document, userId: user.id)
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
            }
        }
    }
    
    func edit(document: Document) {
        selectedDocument = document
    }
    
    func unsetDocument() {
        selectedDocument = nil
    }
    
    func saveDocument(document: Document) {
        Task {
            defer { getAllDocuments() }
            do {
               try await repository.documentRepository.updateDocument(document: document)
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
            }
        }
    }
}
