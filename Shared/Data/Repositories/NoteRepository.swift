//
//  NoteRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.02.25.
//
import SwiftData
import Foundation

class NoteRepository: RepositoryProtocol {
    var container: ModelContainer 
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func getAllNotes(userId: UUID) throws -> [Note] {
        let date = Date()
        let predicate = #Predicate <Note> { $0.userId == userId && $0.date > date }
        let sortDescriptor = [SortDescriptor(\Note.date, order: .forward)]
        let fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: sortDescriptor)
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func deleteNote(note: Note) {
        container.mainContext.delete(note)
    }
    
    func insert(note: Note) {
        container.mainContext.insert(note)
        
        Task {
            do {
                if await NotificationService.getAuthStatus() && note.wantNotification {
                    try NotificationService.setNotification(for: note)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func update(note: Note) throws {
        container.mainContext.insert(note)
        try container.mainContext.save()
        
        Task {
            do {
                if await NotificationService.getAuthStatus() && note.wantNotification { 
                    NotificationService.deleteNotification(id: note.id)
                    
                    try NotificationService.setNotification(for: note)
                }
            } catch {
                print(error)
            }
        }
    }
}
