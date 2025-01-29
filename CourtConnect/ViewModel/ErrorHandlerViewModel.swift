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
    
    func handleError(error: Error) {
        self.error = error
        
        print(error.localizedDescription)
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            self.error = nil
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
