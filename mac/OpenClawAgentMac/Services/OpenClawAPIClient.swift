import Foundation

struct StreamChunk {
    let delta: String
    let isFinished: Bool
}

protocol OpenClawAPIClientProtocol {
    func streamChat(messages: [ChatMessage], model: String) -> AsyncThrowingStream<StreamChunk, Error>
}

final class OpenClawAPIClient: OpenClawAPIClientProtocol {
    private let baseURL: URL
    private let apiKey: String
    private let urlSession: URLSession

    init(baseURL: URL, apiKey: String, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.urlSession = urlSession
    }

    func streamChat(messages: [ChatMessage], model: String) -> AsyncThrowingStream<StreamChunk, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: baseURL.appending(path: "/v1/agent/chat"))
                    request.httpMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

                    let payload = ChatRequest(
                        model: model,
                        stream: true,
                        messages: messages.map { ChatMessageDTO(role: $0.role.rawValue, content: $0.content) }
                    )

                    request.httpBody = try JSONEncoder().encode(payload)

                    // NOTE: MVP stub
                    // Replace with URLSession.bytes(for:) and real SSE parsing in M2.
                    let (_, response) = try await urlSession.data(for: request)

                    guard let http = response as? HTTPURLResponse, 200 ..< 300 ~= http.statusCode else {
                        throw URLError(.badServerResponse)
                    }

                    continuation.yield(StreamChunk(delta: "（示例）OpenClaw 已收到请求，后续请接入真实 SSE 流。", isFinished: false))
                    continuation.yield(StreamChunk(delta: "", isFinished: true))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
