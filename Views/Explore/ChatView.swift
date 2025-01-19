import SwiftUI
import UIKit

// MARK: - Models
enum MessageType {
    case text
    case error
}

struct Message: Identifiable {
    let id = UUID()
    var content: String
    let isUser: Bool
    let timestamp: Date
    let type: MessageType
}

// MARK: - ViewModel
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping = false
    @Published var error: String? = nil
    
    // 获取安全区域底部高度
    private var bottomSafeAreaInset: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.bottom
        }
        return 0
    }
    
    func sendMessage(_ content: String) {
        error = nil
        
        // 添加用户输入
        let userMessage = Message(content: content, isUser: true, timestamp: Date(), type: .text)
        messages.append(userMessage)
        
        // 显示处理中状态
        isTyping = true
        
        // 调用工作流处理
        Task {
            do {
                var responseMessage: Message? = nil
                var fullResponse = ""
                
                let stream = try await WorkflowStreamService.shared.sendMessage(content)
                
                for try await chunk in stream {
                    if responseMessage == nil {
                        // 创建新的响应消息
                        responseMessage = Message(
                            content: chunk,
                            isUser: false,
                            timestamp: Date(),
                            type: .text
                        )
                        messages.append(responseMessage!)
                    }
                    
                    // 更新响应内容
                    fullResponse += chunk
                    if let lastIndex = messages.indices.last {
                        messages[lastIndex].content = fullResponse
                    }
                }
                
                isTyping = false
            } catch {
                handleError(error.localizedDescription)
            }
        }
    }
    
    private func handleError(_ errorMessage: String) {
        isTyping = false
        error = errorMessage
        
        let errorMessage = Message(
            content: errorMessage,
            isUser: false,
            timestamp: Date(),
            type: .error
        )
        messages.append(errorMessage)
    }
    
    func clearMessages() {
        messages.removeAll()
    }
    
    func cancelProcess() {
        Task {
            await WorkflowStreamService.shared.cancelStream()
            await MainActor.run {
                isTyping = false
            }
        }
    }
}

// MARK: - Views
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @FocusState private var isFocused: Bool
    @State private var showingClearConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack {
                Text("情绪分析")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showingClearConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
            
            // 消息记录
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isTyping {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            if let error = viewModel.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            
            // 输入区域
            HStack(spacing: 12) {
                TextField("请输入你想分析的内容...", text: $inputText, axis: .vertical)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                    .focused($isFocused)
                    .lineLimit(1...5)
                    .disabled(viewModel.isTyping)
                
                if viewModel.isTyping {
                    Button(action: {
                        viewModel.cancelProcess()
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                    }
                } else {
                    Button(action: {
                        guard !inputText.isEmpty else { return }
                        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.sendMessage(trimmed)
                        inputText = ""
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(inputText.isEmpty ? .gray : Color(red: 0.25, green: 0.25, blue: 0.35))
                    }
                    .disabled(inputText.isEmpty)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: -2)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .alert("清空记录", isPresented: $showingClearConfirmation) {
            Button("取消", role: .cancel) { }
            Button("清空", role: .destructive) {
                viewModel.clearMessages()
            }
        } message: {
            Text("确定要清空所有记录吗？")
        }
    }
}

// MARK: - Supporting Views
struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.25, green: 0.25, blue: 0.35))
                    .foregroundColor(.white)
                    .cornerRadius(18)
            } else {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.type == .error ? Color.red.opacity(0.1) : Color.white)
                    .foregroundColor(message.type == .error ? .red : .black)
                    .cornerRadius(18)
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView()
} 
