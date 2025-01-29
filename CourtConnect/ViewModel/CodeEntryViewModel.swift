//
//  CodeEntryViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import Foundation
import UIKit

@Observable class CodeEntryViewModel {
    var code: [Character] = []
    
    var message: String = " "

    var codeString: [String] {
        return code.map { String($0) }
    }
    
    func addDigit(_ digit: String) {
        if code.count < 6, let char = digit.first {
            code.append(char)
        }
    }

    func deleteLastDigit() {
        if !code.isEmpty {
            code.removeLast()
        }
    }
    
    func generateCode() {
        Task {
            code = []
            let generated = CodeGeneratorHelper.generateCode()
            for char in generated {
                code.append(char)
                try await Task.sleep(for: .seconds(0.1))
            }
        }
    }
    
    func copy() {
        guard !code.isEmpty else {
            message = "No Code generated"
            
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false , block: { [self]_ in 
                message = ""
            })
            return
        }
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = codeString.joined()
        print(codeString.joined())
    }
    
    func past() {
        code = []
        if let pasteboard = UIPasteboard.general.string {
            for char in pasteboard {
                code.append(char)
            }
        }
    }
}
