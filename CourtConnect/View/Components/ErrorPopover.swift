//
//  ErrorPopover.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 25.01.25.
//
import SwiftUI
import Lottie

struct ErrorPopover<Content: View>: View {
    @Environment(\.errorHandler) var errorHanler 
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            content()
            
            if let error = errorHanler.error {
               VStack {
                   HStack {
                       Text(error.localizedDescription)
                   }
                   .frame(maxWidth: .infinity)
                   .padding()
                   .padding(.horizontal)
                   .background(Material.thickMaterial.opacity(0.9))
                   .cornerRadius(10)
                   
                   Spacer()
               }
               .padding()
               .transition(.move(edge: .top))
            }
       }
        .animation(.easeInOut, value: errorHanler.error != nil)
    }
} 

#Preview {
    @Previewable @State var viewModel = ErrorHandlerViewModel.shared
    ZStack {
        Button("Handle Error") {
            viewModel.handleError(error: UserError.userIdNotFound)
        }
    }
    .errorPopover()
}
