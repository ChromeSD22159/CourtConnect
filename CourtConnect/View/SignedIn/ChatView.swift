//
//  ChatView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import SwiftUI
import Auth

struct ChatView: View {
    @State var viewModel: ChatRoomViewModel
    @State var scrollPosition = ScrollPosition()
    
    init(repository: Repository, myUser: UserProfile, recipientUser: UserProfile) {
        viewModel = ChatRoomViewModel(repository: repository, myUser: myUser, recipientUser: recipientUser)
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 20) {
                    if !viewModel.messages.isEmpty {
                        ForEach(viewModel.messages) { message in
                            if let decrypted = message.decryptMessage() {
                                MessageRow(message: decrypted, myUserId: viewModel.myUser.userId)
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                        }
                    }
                }
                .padding()
                .scrollTargetLayout()
            }
            .contentMargins(.bottom, 75)
            .scrollPosition($scrollPosition)
            .scrollIndicators(.hidden)
        }
        .overlay(alignment: .bottom) {
            InputField(vm: viewModel, scrollPosition: $scrollPosition) {
                viewModel.addMessage(senderID: viewModel.myUser.userId, recipientId: viewModel.recipientUser.userId)
            }
        }
        .onAppear {
            viewModel.getAllMessages()
        }
        .onChange(of: viewModel.messages, {
            withAnimation {
                scrollPosition.scrollTo(edge: .bottom)
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 20) {
                    Menu {
                        let cal = Calendar.current
                        let string = cal.isDateInToday(viewModel.recipientUser.lastOnline) ? "heute, um" : "am " + viewModel.recipientUser.lastOnline.formattedDate()
                        Text("Zuletzt Online, \(string + " " + viewModel.recipientUser.lastOnline.formattedTime()) Uhr")
                            .font(.caption)
                        
                        Button("Reload Chat") {
                            viewModel.getAllMessages()
                        }
                        
                        Button("Delete Local Chat") {
                            viewModel.deleteAll() 
                        }
                    } label: {
                        Text(viewModel.recipientUser.inizials)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background {
                                Circle().fill(Material.ultraThin)
                            }
                            .padding(5)
                    }
                }
            }
        }
        .navigationTitle(viewModel.recipientUser.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}

fileprivate struct InputField: View {
    @ObservedObject var vm: ChatRoomViewModel
    @Binding var scrollPosition: ScrollPosition
    let onPressSend: () -> Void
    
    var body: some View {
        HStack {
            TextField("Deine Nachricht", text: $vm.inputText, prompt: Text("Deine Nachricht"))
                .padding(.leading)
            RoundImageButton(vm: vm, systemName: "paperplane") {
                onPressSend()
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
        VStack(spacing: 8) {
            HStack {
                if message.senderId == myUserId {
                    Text(message.message)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(.orange.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer()
                } else if message.recipientId == myUserId {
                    Spacer()
                    
                    Text(message.message)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Material.thick)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            HStack(spacing: 15) {
                if message.senderId == myUserId {
                    Text(message.createdAt.formatted(.dateTime.hour().minute()))
                        .font(.caption)
                    
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(message.readedAt != nil ? Color.primary : Color.gray)
                    
                    Spacer()
                } else if message.recipientId == myUserId {
                    Spacer()
                    Text(message.createdAt.formatted(.dateTime.hour().minute()))
                        .font(.caption)
                    
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(message.readedAt != nil ? Color.primary : Color.gray)
                        .padding(.trailing, 10)
                }
            }
        }
    }
}
 
fileprivate struct RoundImageButton: View {
    @ObservedObject var vm: ChatRoomViewModel
    let systemName: String
    var onComplete: () -> Void
    var body: some View {
        Image(systemName: systemName)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(10)
            .background {
                Circle().fill(
                    withAnimation(.easeInOut) {
                        vm.inputText.count > 0 ? .orange : .gray
                    }
                )
            }
            .padding(5)
            .onTapGesture {
                if vm.inputText.count > 0 {
                    onComplete()
                }
            }
    }
}
 
#Preview {
    @Previewable @State var vm = ChatRoomViewModel(repository: Repository(type: .preview), myUser: MockUser.myUserProfile, recipientUser: MockUser.userList[1])
  
    NavigationStack {
        ChatView(repository: Repository(type: .preview), myUser: vm.myUser, recipientUser: vm.recipientUser)
    }
 }

