//
//  TeamRequestsView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import SwiftUI 

@MainActor struct TeamRequestsView: View {
    @State var viewModel: TeamRequestsViewModel
    
    init(teamId: UUID) {
        #if targetEnvironment(simulator)
        self.viewModel = TeamRequestsViewModel(repository: RepositoryPreview.shared, teamId: teamId)
        print("RepositoryPreview")
        #else
        self.viewModel = TeamRequestsViewModel(repository: Repository.shared)
        print("Repository")
        #endif
    }
    
    var body: some View {
        ZStack {
            List {
                if viewModel.requests.isEmpty {
                    Section {
                        HStack {
                            Text("Currently no Requests!")
                            
                            Spacer()
                        }
                    }
                } else {
                    Section {
                        ForEach(viewModel.requests) { requestUser in
                            HStack {
                                RequestAcceptionField(requestUser: requestUser) {
                                    viewModel.grandRequest()
                                } rejectRequest: {
                                    viewModel.rejectRequest()
                                }
 
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Requests")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            Task {
                viewModel.isLoading = true
                await viewModel.syncRemoteRequests()
                await viewModel.getLocalRequests()
                viewModel.isLoading = false
            }
        }
        .task {
            await viewModel.getLocalRequests()
        }
        .listBackground()
    }
}

fileprivate struct RequestAcceptionField: View {
    @State var isPresenting = false
    let requestUser: RequestUser
    let grandRequest: () -> Void
    let rejectRequest: () -> Void
    var body: some View {
        Text(requestUser.userProfile.fullName)
            .onTapGesture {
                isPresenting.toggle()
            }
            .alert("Team request from \(requestUser.userProfile.fullName)", isPresented: $isPresenting) {
                Button("Grant") { grandRequest() }
                
                Button("Reject") { rejectRequest() }
            } message: {
                Text("\(requestUser.userProfile.fullName) wants to join your team. Would you like to accept the request?")
            }

    }
}
 
#Preview {
    let userId = MockUser.myUserProfile.userId
    let teamId = MockUser.teamId
    let userProfile = MockUser.userList.randomElement()!
    let userAccount = UserAccount(userId: userId, teamId: teamId, position: "Position", role: "Spieler", displayName: "Spieler", createdAt: Date(), updatedAt: Date())
    let request = RequestUser(userAccount: userAccount, userProfile: userProfile)
    RequestAcceptionField(requestUser: RequestUser(userAccount: userAccount, userProfile: userProfile)) {
        
    } rejectRequest: {
        
    }
}
 
#Preview {
    TeamRequestsView(teamId: MockUser.teamId)
}
