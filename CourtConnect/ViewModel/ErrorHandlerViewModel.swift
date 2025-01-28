//
//  Errorhandler.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.01.25.
//
import Observation
import Foundation

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
