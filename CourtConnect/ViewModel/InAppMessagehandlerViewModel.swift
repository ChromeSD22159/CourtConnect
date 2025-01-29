//
//  InAppMessagehandlerViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.01.25.
//
import Foundation
import SwiftUI
 
@Observable class InAppMessagehandlerViewModel: Observable {
    static let shared = InAppMessagehandlerViewModel()
    
    var message: InAppMessage?
    
    func handleMessage(message: InAppMessage) {
        self.message = message
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            self.message = nil
        })
    }
}

private struct InAppMessageKey: EnvironmentKey {
    static let defaultValue: InAppMessagehandlerViewModel = InAppMessagehandlerViewModel.shared
}

extension EnvironmentValues {
    var messagehandler: InAppMessagehandlerViewModel {
        get { self[InAppMessageKey.self] }
        set { self[InAppMessageKey.self] = newValue }
    }
} 
