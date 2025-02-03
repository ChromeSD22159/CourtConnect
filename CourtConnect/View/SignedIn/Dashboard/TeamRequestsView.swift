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
        self.viewModel = TeamRequestsViewModel(repository: Repository.shared, teamId: teamId)
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
                                    viewModel.grandRequest(request: requestUser.request, userAccount: requestUser.userAccount)
                                } rejectRequest: {
                                    viewModel.rejectRequest(request: requestUser.request)
                                }
 
                                Spacer()
                            }
                        }
                    }
                }
            }
            
            LoadingCard(isLoading: $viewModel.isLoading)
        }
        .navigationTitle("Requests")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.isLoading = true
            Task {
                do {
                    try await viewModel.syncRemoteRequests()
                    try await Task.sleep(for: .seconds(0.8))
                    await viewModel.getLocalRequests()
                    viewModel.isLoading = false
                } catch {
                    await viewModel.getLocalRequests()
                    viewModel.isLoading = false
                }
            }
        }
        .task {
            do {
                try await viewModel.syncRemoteRequests()
                await viewModel.getLocalRequests()
            } catch {
                await viewModel.getLocalRequests()
            }
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
        HStack {
            Text(requestUser.userProfile.fullName)
            
            Text(requestUser.teamID.uuidString)
        }
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
    
    let request = Requests(accountId: userAccount.id, teamId: teamId, createdAt: Date(), updatedAt: Date())
    
    let requestUser = RequestUser(teamID: UUID(), userAccount: userAccount, userProfile: userProfile, request: request)
    RequestAcceptionField(requestUser: requestUser) {
        
    } rejectRequest: {
        
    }
}
 
#Preview {
    TeamRequestsView(teamId: MockUser.teamId)
}
