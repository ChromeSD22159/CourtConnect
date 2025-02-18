//
//  EnterCodeView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftUI 

struct EnterCodeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.errorHandler) var errorHandler
    @State private var viewModel = CodeEntryViewModel() 
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    Image(systemName: "keyboard.badge.ellipsis")
                        .font(.system(size: 100))
                        .foregroundStyle(.darkOrange, Theme.topBottomLinearGradientReverse)
                    
                    HStack {
                        
                        Text("Enter Team's Code")
                            .font(.title2)
                            .fontWeight(.semibold)
                         
                    }
                    
                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                          
                          Text(viewModel.code.indices.contains(index) ? String(viewModel.code[index]) : "_")
                              .font(.system(size: 32))
                              .frame(width: 40, height: 50)
                              .background(Color.gray.opacity(0.2))
                              .cornerRadius(8)
                              .onLongPressGesture(perform: {
                                  viewModel.past()
                              })
                        }
                    }
                    .shake(with: viewModel.numberOfShakes)
                     
                    Button(action: {
                        viewModel.past()
                    }, label: {
                        Label("Insert code", systemImage: "doc.on.clipboard")
                    })
                    .tint(Theme.darkOrange)
                    .buttonStyle(.borderedProminent)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(1..<10, id: \.self) { number in
                            Button(action: {
                                if viewModel.code.count < 6 {
                                    viewModel.addDigit("\(number)")
                                } else {
                                    viewModel.triggerShakeAnimation()
                                }
                            }, label: {
                                Text("\(number)")
                                    .foregroundStyle(Theme.white)
                                    .font(.largeTitle)
                                    .frame(width: 60, height: 60)
                                    .background(Theme.darkOrange.opacity(0.2))
                                    .clipShape(Circle())
                            })
                        }
                         
                        Spacer()
                        
                        Button(action: {
                            viewModel.addDigit("0")
                        }, label: {
                            Text("0")
                                .foregroundStyle(Theme.white)
                                .font(.largeTitle)
                                .frame(width: 60, height: 60)
                                .background(Theme.darkOrange.opacity(0.2))
                                .clipShape(Circle())
                        })
                        
                        Button(action: {
                            viewModel.deleteLastDigit()
                        },
                        label: {
                            Image(systemName: "delete.left")
                                .foregroundStyle(Theme.white)
                                .font(.largeTitle)
                                .frame(width: 60, height: 60)
                                .background(Theme.myGray.opacity(0.2))
                                .clipShape(Circle())
                        })
                    }
                    .padding(.top, 30)
                }
            }
            .navigationTitle(title: "Enter Code")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        dismiss()
                    }.foregroundStyle(Theme.text)
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Join") {
                        Task {
                            do {
                                guard let userAccount = viewModel.userAccount else {
                                    throw UserError.userAccountNotFound
                                }
                                try await viewModel.joinTeamWithCode(userAccount: userAccount)
                                dismiss()
                            } catch {
                                print(error)
                                viewModel.triggerShakeAnimation() 
                                errorHandler.handleError(error: error)
                            }
                        }
                    }
                    .foregroundStyle(Theme.text)
                })
            }
        }.navigationStackTint()
    }
} 
 
#Preview("EnterCode") {
    @Previewable @State var numberOfShakes = 0.0
    ZStack {
        
    }
    .sheet(isPresented: .constant(true), content: {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            EnterCodeView()
        }
    })
    .previewEnvirments()
}
