//
//  ClipboardHelper.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
// 
import UIKit
 
struct ClipboardHelper {
    static func copy(text :String) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
    }
    
    static func past() -> String? {
        UIPasteboard.general.string
    }
}
