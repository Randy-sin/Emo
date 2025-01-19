import Foundation

class WorkflowStreamService {
    static let shared = WorkflowStreamService()
    private init() {}
    
    // 开场白
    private let welcomeMessage = """
    你好，我是你的心理支持伙伴，很高兴能在这里陪伴你。无论是生活中的困扰，还是心情上的波动，都可以随时告诉我。我会耐心倾听，帮助你一起找到方向。
    你最近有什么特别想聊聊的事情吗？或者，有什么让你感到困惑和想要倾诉的感受吗？这里是一个安全的空间，你可以随意表达。
    """
    
    // 对话轮次计数
    private var messageCount = 0
    private var isFirstMessage = true
    
    // 预设的多轮对话回复
    private let conversationResponses = [
        // 第一轮回复
        "听起来很不错呢！Marscode 一定有它的独特之处。能和我多讲讲你用 Marscode 写代码的具体感受吗？为什么会觉得很快呢？",
        
        // 第二轮回复
        "这种顺畅的感觉一定很棒。那在使用 Marscode 的过程中，有没有遇到过什么小挑战呢？或者有没有哪个特别的功能让你印象深刻呢？",
        
        // 第三轮回复
        "报错确实会让人有些苦恼呢。不过这也说明你在不断探索和尝试呀。你能跟我说说一般会出现哪些报错吗？说不定我们可以一起想想办法来解决。",
        
        // 第四轮回复
        "重复声明的报错确实有点让人头疼呢。那你有没有试着去找出为什么会出现重复声明的情况呢？你觉得有没有什么方法可以避免这种报错呢？",
        
        // 第五轮回复
        "你很有行动力呢！通过搜索相关代码来解决问题，这是个很棒的方法。那你在搜索的过程中有什么新的发现吗？或者有没有找到一些特别有用的资源呢？",
        
        // 第六轮回复
        "不用这么客气呀！你积极地去寻找解决办法，这真的很厉害。那你打算接下来继续搜索吗？还是有其他的思路呢？"
    ]
    
    // 默认回复，当对话超过预设轮次时使用
    private let defaultResponses = [
        "我理解你现在的感受。让我们一起来分析一下：",
        "从你的描述中，我感受到：",
        "1. 你正在经历一些情绪波动",
        "2. 这些感受对你来说可能有些困扰",
        "3. 你正在寻求一些建议和支持",
        "\n我的建议是：",
        "1. 首先，接纳当下的感受，这些情绪都是正常的",
        "2. 可以尝试深呼吸练习，帮助自己平静下来",
        "3. 找到一个安静的空间，给自己一些独处的时间",
        "4. 如果愿意的话，可以和信任的朋友分享这些感受",
        "\n记住，每个人都会经历情绪的起伏，这是很自然的事情。我会一直在这里支持你。",
        "\n你觉得这些建议对你有帮助吗？或者你还有其他想要分享的吗？"
    ]
    
    func sendMessage(_ content: String) async throws -> AsyncStream<String> {
        return AsyncStream { continuation in
            Task {
                do {
                    // 模拟网络延迟
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    if isFirstMessage {
                        // 发送开场白
                        for char in welcomeMessage {
                            if Task.isCancelled { break }
                            continuation.yield(String(char))
                            try await Task.sleep(nanoseconds: 50_000_000)  // 每个字符间隔
                        }
                        isFirstMessage = false
                        continuation.finish()
                        return
                    }
                    
                    // 获取当前轮次的回复内容
                    let responses = messageCount < conversationResponses.count ? 
                        [conversationResponses[messageCount]] : defaultResponses
                    messageCount += 1
                    
                    // 逐句输出内容
                    for response in responses {
                        if Task.isCancelled { break }
                        
                        // 逐字输出
                        for char in response {
                            if Task.isCancelled { break }
                            continuation.yield(String(char))
                            try await Task.sleep(nanoseconds: 50_000_000)  // 每个字符间隔
                        }
                        
                        // 句子之间的停顿
                        try await Task.sleep(nanoseconds: 300_000_000)
                        continuation.yield("\n")
                    }
                } catch {
                    continuation.yield("抱歉，出现了一些问题。")
                }
                
                continuation.finish()
            }
        }
    }
    
    func cancelStream() async {
        // 空实现，保持接口一致性
    }
} 