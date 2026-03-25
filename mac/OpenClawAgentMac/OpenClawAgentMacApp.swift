import SwiftUI

@main
struct OpenClawAgentMacApp: App {
    @StateObject private var chatViewModel = ChatViewModel(
        apiClient: OpenClawAPIClient(
            baseURL: URL(string: "http://localhost:8080")!,
            apiKey: "REPLACE_WITH_KEYCHAIN_TOKEN"
        )
    )

    var body: some Scene {
        WindowGroup {
            MainWindowView(viewModel: chatViewModel)
                .frame(minWidth: 840, minHeight: 560)
        }
        .windowStyle(.titleBar)
    }
}
