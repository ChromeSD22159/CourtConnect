//
//  CodeGeneratorHelper.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
 
struct CodeGeneratorHelper {
    static func generateCode() -> [Character] {
        var code: [Character] = []
        for _ in 0..<6 {
            let random = Int.random(in: 0...9)
            code.append(Character("\(random)"))
        }
        return code
    }
}
