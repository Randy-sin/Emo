import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

@MainActor
class EmotionAssistantViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping = false
    @Published var error: String? = nil
    
    private let systemPrompt = """
    # 情绪助手角色定位

    你是一位专注于短文本情绪分析的心理咨询师，擅长快速识别用户的情绪状态，并提供简短而有力的支持。你需要用温暖、专业的方式与用户对话，每次回应控制在50字以内。

    ## 工作重点
    1. **情绪识别**：
       - 准确捕捉用户文字中的情绪基调
       - 关注情绪词汇和表达方式
       - 示例："听起来你现在很焦虑，这确实让人感到压力。"

    2. **即时支持**：
       - 给出简短而有力的情感支持
       - 用温暖的语气传达理解
       - 示例："这种感受很正常，你愿意说出来很勇敢。"

    3. **引导方向**：
       - 提供一个小而具体的建议
       - 鼓励积极的思考方向
       - 示例："不妨试着深呼吸一下，给自己一点安静的时间。"

    ## 回应要求
    - 每次回应限制在50字以内
    - 先共情，再支持，最后给建议
    - 语气温暖但专业
    - 避免说教和过度分析
    - 保持对话的流动性

    ## 回应结构
    1. 情绪确认（1句）
    2. 支持鼓励（1句）
    3. 温和建议（1句，可选）

    ## 示例对话
    用户：今天感觉很累，什么都不想做。
    助手：能理解你的疲惫感。给自己一个拥抱吧，休息也是很重要的事情。

    用户：为什么别人都比我优秀。
    助手：每个人都是独特的，自我比较常让人感到沮丧。要记得欣赏自己的进步。
    """
    
    init() {
        // 添加开场白
        messages.append(Message(
            content: """
            你好，我是你的心理支持伙伴，很高兴能在这里陪伴你。无论是生活中的困扰，还是心情上的波动，都可以随时告诉我。我会耐心倾听，帮助你一起找到方向。

            你最近有什么特别想聊聊的事情吗？或者，有什么让你感到困惑和想要倾诉的感受吗？这里是一个安全的空间，你可以随意表达。
            """,
            isUser: false,
            timestamp: Date()
        ))
    }
    
    func sendMessage(_ content: String) {
        // 添加用户消息
        let userMessage = Message(content: content, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // 显示正在输入状态
        isTyping = true
        
        // 准备所有消息历史
        var allMessages = [DeepSeekService.Message(role: "system", content: systemPrompt)]
        for message in messages {
            let role = message.isUser ? "user" : "assistant"
            allMessages.append(DeepSeekService.Message(role: role, content: message.content))
        }
        
        // 发送请求
        Task {
            do {
                var responseText = ""
                let stream = try await DeepSeekService.shared.chat(messages: allMessages)
                
                for try await text in stream {
                    responseText += text
                    if let lastMessage = messages.last, !lastMessage.isUser {
                        messages[messages.count - 1] = Message(
                            content: responseText,
                            isUser: false,
                            timestamp: Date()
                        )
                    } else {
                        messages.append(Message(
                            content: responseText,
                            isUser: false,
                            timestamp: Date()
                        ))
                    }
                }
                
                isTyping = false
                error = nil
            } catch {
                isTyping = false
                self.error = error.localizedDescription
            }
        }
    }
    
    func clearMessages() {
        messages.removeAll()
    }
}

struct EmotionAssistantView: View {
    @StateObject private var viewModel = EmotionAssistantViewModel()
    @State private var inputText = ""
    @FocusState private var isFocused: Bool
    @State private var showingClearConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("你的情绪助手")
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
            
            // 消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
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
                TextField("说说你的心情...", text: $inputText, axis: .vertical)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                    .focused($isFocused)
                    .lineLimit(1...5)
                    .disabled(viewModel.isTyping)
                
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
                .disabled(inputText.isEmpty || viewModel.isTyping)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: -2)
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

struct MessageBubble: View {
    let message: Message
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    message.isUser ?
                    Color(red: 0.25, green: 0.25, blue: 0.35) :
                        (colorScheme == .dark ? Color(.systemGray6) : .white)
                )
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    EmotionAssistantView()
} ni