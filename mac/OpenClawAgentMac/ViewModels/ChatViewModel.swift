import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var messages: [ChatMessage] = []
    @Published var isStreaming = false
    @Published var selectedModel = "openclaw-agent-v1"
    @Published var latestError: String?

    private let apiClient: OpenClawAPIClientProtocol

    init(apiClient: OpenClawAPIClientProtocol) {
        self.apiClient = apiClient
    }

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !isStreaming else { return }

        latestError = nil

        let userMessage = ChatMessage(role: .user, content: trimmed)
        messages.append(userMessage)
        inputText = ""

        let assistantID = UUID()
        messages.append(ChatMessage(id: assistantID, role: .assistant, content: ""))

        isStreaming = true

        Task {
            do {
                let stream = apiClient.streamChat(messages: messages, model: selectedModel)

                for try await chunk in stream {
                    if let idx = messages.firstIndex(where: { $0.id == assistantID }) {
                        messages[idx].content += chunk.delta
                    }

                    if chunk.isFinished {
                        isStreaming = false
                    }
                }

                isStreaming = false
            } catch {
                latestError = error.localizedDescription
                isStreaming = false
            }
        }
    }
}
