//
//  NavigationTabBarQrButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 18.02.25.
//
import SwiftUI

struct NavigationTabBarQrButton: View { 
    @State var viewModel = NavigationTabBarQrButtonViewModel()
    var body: some View {
        Image(systemName: "qrcode")
            .padding(5)
            .foregroundStyle(Theme.white)
            .background(Theme.headline)
            .borderRadius(5)
            .onTapGesture {
                viewModel.showSheet()
            }
            .sheet(isPresented: $viewModel.isSheet, onDismiss: {
                viewModel.closeSheet()
            }) {
                SheetStlye(title: "Entry with QR", detents: [.medium], isLoading: .constant(false)) {
                    VStack(alignment: .center, spacing: 30) {
                        if let qrCode = viewModel.qrCode {
                            Image(uiImage: qrCode)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 300, height: 300) 
                                .borderRadius(20)
                        }
                        
                        HStack {
                            Button {
                                ClipboardHelper.copy(text: viewModel.joinCode)
                                
                                InAppMessagehandlerViewModel.shared.handleMessage(message: InAppMessage(icon: .warn, title: "Join code copied"))
                            } label: {
                                Label("Code Team: \(viewModel.joinCode)", systemImage: "arrow.right.doc.on.clipboard")
                            }
                        }
                    }
                    .padding()
                }
            }
    }
}
