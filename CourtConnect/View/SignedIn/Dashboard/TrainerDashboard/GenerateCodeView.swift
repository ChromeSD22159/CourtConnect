//
//  GenerateCodeView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

struct GenerateCodeViewSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = GenerateCodeViewModel()
    var body: some View {
        SheetStlye(title: "Generate Code", detents: [.medium], isLoading: $viewModel.isLoading) {
            VStack(spacing: 20) {
                
                Image(systemName: "keyboard.badge.ellipsis")
                    .font(.system(size: 100))
                    .foregroundStyle(.darkOrange, Theme.topBottomLinearGradientReverse)
                
                Text("Generate a new Code for your team.")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        
                        Text(viewModel.code.indices.contains(index) ? String(viewModel.code[index]) : "_")
                            .font(.system(size: 32))
                            .frame(width: 40, height: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .animation(.spring, value: viewModel.code)
                    }
                }
                
                HStack(spacing: 10) {
                    Button(action: {
                        viewModel.copy()
                    }, label: {
                        Image(systemName: "doc.on.clipboard")
                    })
                    .tint(Theme.lightOrange)
                    .buttonStyle(.borderedProminent)
                    
                    Button("Update Code") {
                        Task {
                            do {
                                try await viewModel.updateTeamCode()
                                dismiss()
                            } catch {
                                ErrorHandlerViewModel.shared.handleError(error: error) 
                            }
                        }
                    }
                    .errorAlert()
                    .tint(Theme.darkOrange)
                    .buttonStyle(.borderedProminent)
                }
            }
        } 
    }
}

#Preview("Generate") {
    @Previewable @State var isSheet = true
    Button("OPEN") {
        isSheet.toggle()
    }
    .sheet(isPresented: $isSheet, content: {
        GenerateCodeViewSheet()
            .errorAlert()
            .previewEnvirments()
    })
}
