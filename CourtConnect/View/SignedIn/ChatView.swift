//
//  ChatView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    
    var userId = "1"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.messages) { message in
                    MessageRow(message: message, userId: userId)
                }
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            HStack {
                ZStack {
                    TextField("", text: $viewModel.inputText)
                }
                .padding()
                .background(Material.ultraThin)
                .clipShape(Capsule())
                
                Image(systemName: "arrowshape.right.circle.fill")
                    .foregroundStyle(.white)
                    .font(.title)
                    .padding(8)
                    .background {
                        Circle()
                    }
                    .onTapGesture {
                        viewModel.addMessage(senderID: "1", recipientId: "2")
                    }
            }
            .padding()
        }
        .navigationTitle("askdjla")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder func MessageRow(message: Chat, userId: String) -> some View {
        VStack(spacing: 5) {
            HStack {
                if message.senderId == userId {
                    Text(message.text)
                    
                    Spacer()
                } else if message.recipientId == userId {
                    Spacer()
                    
                    Text(message.text)
                }
                
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .background(Material.thick)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack {
                Spacer()
                Text(message.createdAt.formatted(.dateTime.hour().minute()) + " Uhr")
                    .font(.caption)
            }
            .padding(.horizontal, 5)
        }
    }
}

#Preview {
    @Previewable @State var vm = ChatRoomViewModel(repository: Repository(type: .preview))
     
    NavigationStack {
        ChatView(viewModel: vm)
            .onAppear {
                vm.messages = [
                    Chat(senderId: "1", recipientId: "2", text: "Hallo wie gehts?", readedAt: nil),
                    Chat(senderId: "2", recipientId: "1", text: "hey gut und dir?", readedAt: nil),
                    Chat(senderId: "1", recipientId: "2", text: "ja mir auch! danke", readedAt: nil)
                ]
            }
    }
}
