//
//  ModelProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
// 
import Foundation
import SwiftData

protocol ModelProtocol: Identifiable, PersistentModel, SupabaseEntitiy {
    associatedtype DTO: DTOProtocol
    func toDTO() -> DTO
}
