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
                       Text(message.title)
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
            } else if let message = errorHanler.error {
               VStack {
                   HStack {
                       Text(message.localizedDescription)
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
        .animation(.easeInOut, value: messagehandler.message != nil)
    }
}
 
#Preview {
    @Previewable @State var viewModel = InAppMessagehandlerViewModel.shared
    ZStack {
        Button("Handle Message") {
            viewModel.handleMessage(message: InAppMessage(title: "Neue Nachricht von Frederik", body: "Neue Nachricht von Frederik"))
        }
    }.messagePopover()
}
