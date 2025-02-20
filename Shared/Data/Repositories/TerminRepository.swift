//
//  TerminRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 20.02.25.
//
import SwiftData
import Foundation

@MainActor
class TerminRepository: RepositoryProtocol {
    var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func getPastTeamTermine(for teamId: UUID) throws -> [Termin] {
        let date = Date()
        let predicate = #Predicate<Termin> { $0.startTime < date && $0.teamId == teamId && $0.deletedAt == nil }
        let sortBy = [SortDescriptor(\Termin.startTime, order: .reverse)]
        let fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: sortBy)
        let result = try container.mainContext.fetch(fetchDescriptor)
        return result
    }
    
    func getTermineBy(id: UUID) throws -> Termin? {
        let predicate = #Predicate<Termin> { $0.id == id && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let result = try container.mainContext.fetch(fetchDescriptor)
        return result.first
    }
    
    func getTeamTermine(for teamId: UUID) throws -> [Termin] {
        let date = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<Termin> { $0.startTime > date && $0.teamId == teamId && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let result = try container.mainContext.fetch(fetchDescriptor)
        return result
    }
}
