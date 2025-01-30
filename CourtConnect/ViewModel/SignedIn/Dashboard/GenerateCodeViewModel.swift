//
//  GenerateCodeViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation

@Observable class GenerateCodeViewModel {
    let repository: BaseRepository
    
    init(repository: BaseRepository) {
        self.repository = repository
    }
    
    var code: [Character] = [] 
    var message: String = " "
    var codeString: [String] {
        return code.map { String($0) }
    }
    
    func copy() {
        guard !code.isEmpty else {
            message = "No Code generated"
            
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false , block: { [self]_ in
                message = ""
            })
            return
        }
        
        ClipboardHelper.copy(text: codeString.joined())
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
}
