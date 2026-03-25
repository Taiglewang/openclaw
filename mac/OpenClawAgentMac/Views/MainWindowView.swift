import SwiftUI

struct MainWindowView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            messageList
            Divider()
            inputBar
        }
        .padding(12)
    }

    private var header: some View {
        HStack {
            Text("OpenClaw Agent")
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()

            Picker("Model", selection: $viewModel.selectedModel) {
                Text("openclaw-agent-v1").tag("openclaw-agent-v1")
                Text("openclaw-agent-reasoner").tag("openclaw-agent-reasoner")
            }
            .frame(width: 240)

            if viewModel.isStreaming {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(.bottom, 8)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.role.rawValue.uppercased())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(message.content.isEmpty ? "…" : message.content)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .background(backgroundColor(for: message.role))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .id(message.id)
                    }
                }
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastID = viewModel.messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var inputBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let error = viewModel.latestError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            HStack(alignment: .bottom, spacing: 8) {
                TextEditor(text: $viewModel.inputText)
                    .font(.body)
                    .frame(minHeight: 80, maxHeight: 140)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    }

                Button {
                    viewModel.sendMessage()
                } label: {
                    Text(viewModel.isStreaming ? "发送中" : "发送")
                        .frame(width: 80)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isStreaming)
            }
        }
        .padding(.top, 10)
    }

    private func backgroundColor(for role: MessageRole) -> Color {
        switch role {
        case .user:
            return .blue.opacity(0.12)
        case .assistant:
            return .gray.opacity(0.12)
        case .system:
            return .orange.opacity(0.12)
        case .tool:
            return .green.opacity(0.12)
        }
    }
}

#Preview {
    MainWindowView(
        viewModel: ChatViewModel(
            apiClient: OpenClawAPIClient(baseURL: URL(string: "http://localhost:8080")!, apiKey: "demo")
        )
    )
}
