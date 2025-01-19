@Model class SyncHistory: Identifiable {
    var id: UUID
    var userId: String
    var table: String
    var timestamp: Date
    
    init(id: UUID = UUID(), userId: String, table: String, timestamp: Date) {
        self.id = id
        self.userId = userId
        self.table = table
        self.timestamp = timestamp
    }
}