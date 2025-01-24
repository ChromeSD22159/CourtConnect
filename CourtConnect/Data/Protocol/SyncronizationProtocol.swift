//
//  SyncronizationProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import Foundation
import SwiftData

@MainActor protocol SyncronizationProtocol {
    associatedtype LocalModel: PersistentModel
    associatedtype RemoteDTO: Codable
    var backendClient: BackendClient { get set }
    var container: ModelContainer { get set }
    func usert(item: LocalModel) throws
    func softDelete(item: UserAccount) throws
    func sendUpdatedAfterLastSyncToBackend(userId: String, lastSync: Date) async
    func sendToBackend(item: LocalModel) async throws
    func fetchFromServer(after: Date) async throws -> [RemoteDTO]
}
