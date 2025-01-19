import SwiftUI

// 认知技巧模型
struct CognitiveTechnique: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

// 主题类型枚举
enum ThemeType {
    case selfLove
    case selfCare
    case buildHappiness
    
    var title: String {
        switch self {
        case .selfLove: return "好好爱自己"
        case .selfCare: return "关心自己"
        case .buildHappiness: return "打造自己的幸福"
        }
    }
    
    var description: String {
        switch self {
        case .selfLove:
            return "练习将自己放在第一位，以善意和尊重对待自己。这裏引导妳以平衡的方式爱自己，关注妳的幸福和健康，无论妳现在的状况如何。"
        case .selfCare:
            return "在这个快节奏的生活中，我们常常忘记关心自己。这个主题将帮助你学会觉察自己的需要，建立健康的自我关怀习惯，让身心都能得到良好的照顾。"
        case .buildHappiness:
            return "幸福不是偶然的产物，而是一种持续的选择和练习。这个主题将帮助你发现生活中的美好，培养积极的心态，学会创造和维持持久的幸福感。"
        }
    }
    
    var techniques: [CognitiveTechnique] {
        switch self {
        case .selfLove:
            return [
                CognitiveTechnique(
                    title: "觉察思维",
                    subtitle: "Awareness Based Cognitive Practice"
                ),
                CognitiveTechnique(
                    title: "放松冥想",
                    subtitle: "Relaxation and Meditation Training"
                ),
                CognitiveTechnique(
                    title: "创意思考",
                    subtitle: "Creative Thinking Method"
                )
            ]
        case .selfCare:
            return [
                CognitiveTechnique(
                    title: "身心觉察",
                    subtitle: "Mind-Body Awareness Practice"
                ),
                CognitiveTechnique(
                    title: "情绪调节",
                    subtitle: "Emotional Regulation Skills"
                ),
                CognitiveTechnique(
                    title: "自我关怀",
                    subtitle: "Self-Care Strategies"
                )
            ]
        case .buildHappiness:
            return [
                CognitiveTechnique(
                    title: "积极心理",
                    subtitle: "Positive Psychology Practice"
                ),
                CognitiveTechnique(
                    title: "感恩练习",
                    subtitle: "Gratitude Training"
                ),
                CognitiveTechnique(
                    title: "幸福规划",
                    subtitle: "Happiness Planning Method"
                )
            ]
        }
    }
    
    var questions: [String] {
        switch self {
        case .selfLove:
            return [
                "平时你是如何爱自己和体贴自己的？",
                "回想一下最近你对自己特别苛刻的时候，发生了什么？你的反应又是什么？如果场景重现，你会如何展现自己的共情、理解和支持？",
                "当你感到压力或焦虑时，你通常会如何安抚自己？有哪些方式能让你感到被理解和支持？",
                "你认为自我关爱对你的生活和心理健康有什么影响？它如何帮助你更好地面对生活中的挑战？",
                "展望未来，你希望如何继续培养和加强自我关爱的能力？有什么具体的小目标和行动计划吗？"
            ]
        case .selfCare:
            return [
                "在日常生活中，你最容易忽视自己哪些方面的需求？这些需求对你的身心健康有什么影响？",
                "当你感到疲惫或压力大时，你通常会采取什么方式来照顾自己？这些方式效果如何？",
                "你觉得什么时候最需要关心自己？在这些时刻，你希望得到怎样的关怀和支持？",
                "回想一下最近一次你很好地照顾了自己的经历，当时你做了什么？这些行动给你带来了什么感受？",
                "如果为自己制定一个自我关怀计划，你会包含哪些具体的行动？如何确保这些行动可以持续进行？"
            ]
        case .buildHappiness:
            return [
                "回想最近让你感到幸福的时刻，是什么让这些时刻变得特别？这些经历告诉你什么是真正重要的？",
                "你认为幸福的生活应该是什么样子的？目前你离这个理想还有多远？哪些方面已经做得不错，哪些还需要改进？",
                "在面对困难和挫折时，你是如何保持积极心态的？有哪些方法帮助你重新找到希望和动力？",
                "生活中有哪些人或事让你感到感恩？这些人或事如何影响了你的生活质量和幸福感？",
                "如果要为自己制定一个提升幸福感的计划，你会包含哪些具体的行动？如何确保这些行动持续有效？"
            ]
        }
    }
} 