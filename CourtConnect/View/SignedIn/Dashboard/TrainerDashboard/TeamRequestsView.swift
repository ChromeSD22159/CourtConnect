//
//  TeamRequestsView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import SwiftUI 

@MainActor struct TeamRequestsView: View {
    @State var viewModel: TeamRequestsViewModel
    
    init(teamId: UUID, userId: UUID) {
        self.viewModel = TeamRequestsViewModel(repository: Repository.shared, teamId: teamId, userId: userId)
    }
    
    var body: some View {
        AnimationBackgroundChange {
            List {
                ListInfomationSection(text: "This list shows all open accession requests for your team.  Select an inquiry to see the details and edit them.")
                
                Section {
                    if viewModel.requests.isEmpty {
                        ContentUnavailableView("No join requests", systemImage: "figure", description: Text("There is currently no accession request."))
                    } else {
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
                .blurrylistRowBackground()
            }
            
            LoadingCard(isLoading: $viewModel.isLoading)
        } 
        .navigationTitle(title: "Requests")
        .listBackgroundAnimated()
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
            
            Text("\(requestUser.request.createdAt.formattedDate()) - \(requestUser.request.createdAt.formattedTime())")
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
    AnimationBackgroundChange {
        List {
            ListInfomationSection(text: "This list shows all open accession requests for your team.  Select an inquiry to see the details and edit them.")
            
            Section {
                ContentUnavailableView("No join requests", systemImage: "figure", description: Text("There is currently no accession request."))
            }
            .blurrylistRowBackground()
            
        }
        .listBackgroundAnimated()
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
    TeamRequestsView(teamId: MockUser.teamId, userId: MockUser.myUserAccount.userId)
}
