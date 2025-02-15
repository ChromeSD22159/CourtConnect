//
//  DocumentRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftData
import Foundation
import Supabase
import UIKit

@MainActor class DocumentRepository {
    var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func insert(document: DocumentDTO, userId: UUID) {
        do {
            container.mainContext.insert(document.toModel())
             
            let newSyncHistoryTimeStamp = SyncHistory(table: .document, userId: userId)
            container.mainContext.insert(newSyncHistoryTimeStamp)
            try container.mainContext.save()
        } catch {
            print(error)
        }
    } 
    
    func getDocuments(for teamId: UUID) throws -> [Document] {
        let predicate = #Predicate<Document> { $0.teamId == teamId && $0.deletedAt == nil }
        
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func uploadCachedDocument(image: UIImage, fileName: String, info: String, bucket: SupabaseBucket, teamId: UUID) async throws -> DocumentDTO {
        try await SupabaseService.uploadImageToSupabaseAndCache(image: image, fileName: fileName, info: info, bucket: bucket, teamId: teamId)
    }
    
    func downloadDocument(imageURL: String, bucket: SupabaseBucket) async throws -> URL {
        return try await SupabaseService.downloadDocumentAndCache(imageURL: imageURL, bucket: bucket)
    }
     
    func softDelete(document: Document, userId: UUID) async throws {
        document.updatedAt = Date()
        document.deletedAt = Date()
        container.mainContext.insert(document)
        
        let newSyncHistoryTimeStamp = SyncHistory(table: .document, userId: userId)
        container.mainContext.insert(newSyncHistoryTimeStamp)
        try container.mainContext.save()
        
        try await SupabaseService.upsertWithOutResult(item: document.toDTO(), table: .document, onConflict: "id")
    }
    
    func updateDocument(document: Document) async throws {
        document.updatedAt = Date()
        
        container.mainContext.insert(document)
        try container.mainContext.save()
        
        try await SupabaseService.upsertWithOutResult(item: document.toDTO(), table: .document, onConflict: "id")
    }
}
