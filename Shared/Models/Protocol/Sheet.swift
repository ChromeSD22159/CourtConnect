//
//  Sheet.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
// 
import Foundation
  
@MainActor protocol Sheet: ObservableObject, OnAppiearAnimation {
    var isSheet: Bool { get set }
    var isLoading: Bool { get set } 
}

extension Sheet {
    func toggleSheet() {
        isSheet.toggle()
    }

    func loadingManager(onComplete: () async throws -> Void) async throws {
        isLoading = true
        defer { isLoading = false }
        try await onComplete()
    }
}
