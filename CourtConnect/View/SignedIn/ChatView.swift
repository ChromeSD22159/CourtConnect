//
//  ChatView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import SwiftUI
import Auth

struct ChatView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var scrollPosition = ScrollPosition()
    let myUser: UserProfile
    let otherUser: UserProfile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.messages) { message in
                    MessageRow(message: message, myUserId: myUser.userId)
                }
            }
            .padding()
        }
        .contentMargins(.bottom, 75)
        .scrollPosition($scrollPosition)
        .onAppear { scrollPosition.scrollTo(edge: .bottom) }
        .overlay(alignment: .bottom) {
            InputField(viewModel: viewModel, scrollPosition: $scrollPosition, myUser: myUser, otherUser: otherUser)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 20) {
                    Image(systemName: "figure")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background {
                            Circle()
                                .background(Material.ultraThin)
                        }
                        .padding(5)
                }
            }
        }
        .navigationTitle(otherUser.firstName + otherUser.lastName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct InputField: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @Binding var scrollPosition: ScrollPosition
    let myUser: UserProfile
    let otherUser: UserProfile
    var body: some View {
        HStack {
            RoundImageButton(systemName: "camera") {
                
            }
            
            TextField("", text: $viewModel.inputText, prompt: Text("Deine Nachricht"))
                .padding(.leading)
            
            RoundImageButton(systemName: "paperplane") {
                withAnimation {
                    viewModel.addMessage(senderID: myUser.userId, recipientId: otherUser.userId)
                    
                    scrollPosition.scrollTo(edge: .bottom)
                }
            }
        }
        .background(Material.ultraThin)
        .clipShape(Capsule())
        .shadow(radius: 15, y: 10)
        .padding()
    }
}

fileprivate struct MessageRow: View {
    let message: Chat
    let myUserId: String
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                if message.senderId == myUserId {
                    Text(message.text)
                    
                    Spacer()
                } else if message.recipientId == myUserId {
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

// TODO: REFACTOR
struct RoundImageButton: View {
    let systemName: String
    var onComplete: () -> Void
    var body: some View {
        Image(systemName: systemName)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(10)
            .background {
                Circle().background(Material.ultraThin)
            }
            .padding(5)
            .onTapGesture {
                onComplete()
            }
    }
}

#Preview {
    Text("")
}

/*
 
 #Preview {
     @Previewable @State var vm = ChatRoomViewModel(repository: Repository(type: .preview))
     let myUser = UserProfile(userId: UUID().uuidString, firstName: "Frederik", lastName: "Kohler", roleString: "", birthday: "", createdAt: Date(), updatedAt: Date(), lastOnline: Date())
     
     let otherUser = UserProfile(userId: UUID().uuidString, firstName: "Sabina", lastName: "Hodel", roleString: "", birthday: "", createdAt: Date(), updatedAt: Date(), lastOnline: Date())
     
     NavigationStack {
         ChatView(viewModel: vm, myUser: myUser, otherUser: otherUser)
             .onAppear {
                 let myId = myUser.userId
                 let otherId = otherUser.userId
                 vm.messages = [
                     Chat(senderId: myId, recipientId: otherId, text: "Hallo wie gehts?", readedAt: nil),
                     Chat(senderId: otherId, recipientId: myId, text: "hey gut und dir?", readedAt: nil),
                     Chat(senderId: myId, recipientId: otherId, text: "ja mir auch! danke", readedAt: nil),
                     Chat(senderId: myId, recipientId: otherId, text: "Hallo wie gehts?", readedAt: nil),
                     Chat(senderId: otherId, recipientId: myId, text: "hey gut und dir?", readedAt: nil),
                     Chat(senderId: myId, recipientId: otherId, text: "ja mir auch! danke", readedAt: nil),
                     Chat(senderId: myId, recipientId: otherId, text: "Hallo wie gehts?", readedAt: nil),
                     Chat(senderId: otherId, recipientId: myId, text: "hey gut und dir?", readedAt: nil),
                     Chat(senderId: myId, recipientId: otherId, text: "ja mir auch! danke", readedAt: nil),
                     Chat(senderId: myId, recipientId: otherId, text: "Hallo wie gehts?", readedAt: nil),
                     Chat(senderId: otherId, recipientId: myId, text: "hey gut und dir?", readedAt: nil),
                     Chat(senderId: myId, recipientId: otherId, text: "ja mir auch! danke", readedAt: nil)
                 ]
             }
     }
 }
 */
