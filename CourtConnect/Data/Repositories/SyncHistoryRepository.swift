@MainActor
class SyncHistoryRepository {
    let type: RepositoryType
    let container: ModelContainer 
     
    init(container: ModelContainer, type: RepositoryType) {
        self.type = type
        self.container = container
    }
}