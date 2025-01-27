//
//  MessageSheet.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.01.25.
//
import SwiftUI

struct MessagePopover<Content: View>: View {
    @State var viewModel = InAppMessagehandler.shared
    @State var errorHanler = ErrorHandlerViewModel.shared
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            content()
            
            if let message = viewModel.message {
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
        .animation(.easeInOut, value: viewModel.message != nil)
    }
}
 
#Preview {
    @Previewable @State var viewModel = InAppMessagehandler.shared
    ZStack {
        Button("Handle Message") {
            viewModel.handleMessage(message: InAppMessage(title: "Neue Nachricht von Frederik", body: "Neue Nachricht von Frederik"))
        }
    }.messagePopover()
}
