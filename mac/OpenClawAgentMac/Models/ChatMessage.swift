import Foundation

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
    case tool
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: MessageRole
    var content: String
    let createdAt: Date

    init(id: UUID = UUID(), role: MessageRole, content: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
}

struct ChatRequest: Codable {
    let model: String
    let stream: Bool
    let messages: [ChatMessageDTO]
}

struct ChatMessageDTO: Codable {
    let role: String
    let content: String
}
