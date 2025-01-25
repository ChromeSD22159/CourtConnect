//
//  MessagePopoverViewModifier.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 22.01.25.
//
import SwiftUI

struct MessagePopoverViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        MessagePopover {
            content
        }
    }
}

struct ErrorPopoverViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        MessagePopover {
            content
        }
    }
}

extension View {
    func messagePopover() -> some View {
        modifier(MessagePopoverViewModifier())
    }
    
    func errorPopover() -> some View {
        modifier(MessagePopoverViewModifier())
    }
}
