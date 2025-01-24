//
//  SyncronizationViewModelProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
// 
import Foundation
 
@MainActor protocol SyncronizationViewModelProtocol {
    var repository: Repository { get set}
    var userId: String? { get set}
    func getLastSyncDate(userId: String) throws -> Date
    func sendToServer(account: UserAccount) async throws
    func importAccountsAfterLastSyncFromBackend()
    func sendUpdatedAfterLastSyncToBackend()
}
