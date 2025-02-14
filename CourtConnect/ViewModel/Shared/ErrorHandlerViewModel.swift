//
//  Errorhandler.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.01.25.
//
import Observation
import Foundation
import SwiftUI

@Observable class ErrorHandlerViewModel: Observable {
    static let shared = ErrorHandlerViewModel()
    var error: Error?
    var errorString: String?
    
    func handleError(error: Error) {
        guard !ErrorIdentifier.isInternetLost(error: error) else {
            print("Internet error ignored")
            return
        }
        guard !ErrorIdentifier.isConnectionTimedOut(error: error) else {
            print("Internet error ignored")
            return
        }
        guard self.error == nil else { return }
        self.error = error
        self.errorString = error.localizedDescription
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            self.error = nil
            self.errorString = nil
        })
    }
} 
 
struct ErrorHandlerKey: EnvironmentKey {
    static let defaultValue: ErrorHandlerViewModel = ErrorHandlerViewModel.shared
}

extension EnvironmentValues {
    var errorHandler: ErrorHandlerViewModel {
        get { self[ErrorHandlerKey.self] }
        set { self[ErrorHandlerKey.self] = newValue }
    }
}
