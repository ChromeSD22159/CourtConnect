//
//  MessageSheet.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.01.25.
//
import SwiftUI 

struct MessagePopover<Content: View>: View {
    @Environment(\.messagehandler) var messagehandler
    @Environment(\.errorHandler) var errorHanler
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            content()
            
            if let message = messagehandler.message {
               VStack {
                   HStack {
                       if let icon = message.icon {
                           Text(icon.rawValue)
                           Text(message.title)
                       } else {
                           Text(message.title)
                       }
                       
                   }
                   .frame(maxWidth: .infinity)
                   .padding()
                   .padding(.horizontal)
                   .background(Material.thickMaterial.opacity(0.9))
                   .cornerRadius(10)
                   
                   Spacer()
               }
               .padding(.top, 25)
               .padding()
               .transition(.move(edge: .top))
            } else if let errorString = errorHanler.errorString {
               VStack {
                   HStack {
                       Text("\(MessageIcon.warn.rawValue) \(errorString)")
                   }
                   .frame(maxWidth: .infinity)
                   .padding()
                   .padding(.horizontal)
                   .background(Material.thickMaterial.opacity(0.9))
                   .cornerRadius(10)
                   
                   Spacer()
               }
               .padding(.top, 25)
               .padding()
               .transition(.move(edge: .top))
           }
       }
        .animation(.easeInOut, value: messagehandler.message != nil)
    }
}
 
#Preview {
    @Previewable @State var viewModel = InAppMessagehandlerViewModel.shared
    ZStack {
        Button("Handle Message") {
            viewModel.handleMessage(message: InAppMessage(title: "Neue Nachricht von Frederik", body: "Neue Nachricht von Frederik"))
        }
    }.previewEnvirments()
}

#Preview {
    @Previewable @State var viewModel = ErrorHandlerViewModel.shared
    ZStack {
        Button("Handle Error") {
            do {
                throw UserError.signInFailed
            } catch {
                viewModel.handleError(error: error)
            }
        }
    }.previewEnvirments()
}
