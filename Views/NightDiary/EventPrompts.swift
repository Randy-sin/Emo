import Foundation
import SwiftUI

enum NightDiary { }

extension NightDiary {
    struct EventPrompt {
        let event: String
        let descriptionPrompt: DescriptionPrompt
        let futurePrompt: FuturePrompt
        let expectationPrompt: ExpectationPrompt
        
        struct DescriptionPrompt {
            let title: String
            let description: String
        }
        
        struct FuturePrompt {
            let title: String
        }
        
        struct ExpectationPrompt {
            let title: String
        }
    }
    
    static let eventPrompts: [String: EventPrompt] = [
        "学习": EventPrompt(
            event: "学习",
            descriptionPrompt: .init(
                title: "今天的学习给你带来了什么收获？",
                description: "因为今天选择专注的事情是学习"
            ),
            futurePrompt: .init(
                title: "👍很棒！明天有什么想要学习的内容吗？"
            ),
            expectationPrompt: .init(
                title: "如果明天的学习特别顺利，你希望能收获什么？😊"
            )
        ),
        "工作": EventPrompt(
            event: "工作",
            descriptionPrompt: .init(
                title: "今天的工作中有什么让你感到满意的地方？",
                description: "因为今天选择专注的事情是工作"
            ),
            futurePrompt: .init(
                title: "💪明天工作有什么想要完成的目标？"
            ),
            expectationPrompt: .init(
                title: "期待明天的工作能带来什么样的成就感？✨"
            )
        ),
        "朋友": EventPrompt(
            event: "朋友",
            descriptionPrompt: .init(
                title: "和朋友相处的时光带给你什么感动？",
                description: "因为今天选择专注的事情是朋友"
            ),
            futurePrompt: .init(
                title: "👥明天想和朋友分享什么有趣的事情？"
            ),
            expectationPrompt: .init(
                title: "期待和朋友之间会有什么温暖的互动？🌟"
            )
        ),
        "恋人": EventPrompt(
            event: "恋人",
            descriptionPrompt: .init(
                title: "今天与恋人相处的甜蜜时刻是什么？",
                description: "因为今天选择专注的事情是恋人"
            ),
            futurePrompt: .init(
                title: "💑明天想和恋人一起做什么？"
            ),
            expectationPrompt: .init(
                title: "期待明天能和恋人创造什么美好的回忆？💕"
            )
        ),
        "家人": EventPrompt(
            event: "家人",
            descriptionPrompt: .init(
                title: "今天和家人相处的温馨时刻是什么？",
                description: "因为今天选择专注的事情是家人"
            ),
            futurePrompt: .init(
                title: "👨‍👩‍👧‍👦明天想和家人一起做什么？"
            ),
            expectationPrompt: .init(
                title: "期待明天能和家人分享什么快乐？🏠"
            )
        ),
        "食物": EventPrompt(
            event: "食物",
            descriptionPrompt: .init(
                title: "今天吃到了什么让你感到幸福的美食？",
                description: "因为今天选择专注的事情是食物"
            ),
            futurePrompt: .init(
                title: "🍜明天想尝试什么美味？"
            ),
            expectationPrompt: .init(
                title: "期待明天能发现什么令人惊喜的美食？😋"
            )
        ),
        "娱乐": EventPrompt(
            event: "娱乐",
            descriptionPrompt: .init(
                title: "今天的娱乐活动给你带来了什么快乐？",
                description: "因为今天选择专注的事情是娱乐"
            ),
            futurePrompt: .init(
                title: "🎮明天想体验什么有趣的娱乐活动？"
            ),
            expectationPrompt: .init(
                title: "期待明天的娱乐时光会带来什么惊喜？🎡"
            )
        ),
        "运动": EventPrompt(
            event: "运动",
            descriptionPrompt: .init(
                title: "今天的运动给你带来了什么好心情？",
                description: "因为今天选择专注的事情是运动"
            ),
            futurePrompt: .init(
                title: "💪明天想尝试什么运动项目？"
            ),
            expectationPrompt: .init(
                title: "想象明天运动后充满活力的感觉会是什么样的？🏃‍♂️"
            )
        ),
        "爱好": EventPrompt(
            event: "爱好",
            descriptionPrompt: .init(
                title: "今天在爱好中获得了什么乐趣？",
                description: "因为今天选择专注的事情是爱好"
            ),
            futurePrompt: .init(
                title: "💖明天想在爱好上尝试什么新突破？"
            ),
            expectationPrompt: .init(
                title: "期待明天在爱好上会有什么新发现？✨"
            )
        ),
        "旅行": EventPrompt(
            event: "旅行",
            descriptionPrompt: .init(
                title: "今天的旅程中遇到了什么美好的事物？",
                description: "因为今天选择专注的事情是旅行"
            ),
            futurePrompt: .init(
                title: "🌏明天想探索什么新地方？"
            ),
            expectationPrompt: .init(
                title: "期待明天的旅程会带来什么惊喜？🗺️"
            )
        ),
        "宠物": EventPrompt(
            event: "宠物",
            descriptionPrompt: .init(
                title: "今天和宠物相处的温馨时刻是什么？",
                description: "因为今天选择专注的事情是宠物"
            ),
            futurePrompt: .init(
                title: "🐾明天想和宠物一起做什么？"
            ),
            expectationPrompt: .init(
                title: "期待明天和宠物会有什么有趣的互动？🐶"
            )
        )
    ]
    
    static func getRandomPrompt(for events: Set<String>) -> EventPrompt {
        if events.isEmpty {
            return eventPrompts["娱乐"]! // 默认返回娱乐的提示
        }
        
        if events.count == 1, let event = events.first {
            return eventPrompts[event] ?? eventPrompts["娱乐"]!
        }
        
        // 如果有多个事件，随机选择一个
        let randomEvent = Array(events.filter { eventPrompts[$0] != nil }).randomElement() ?? "娱乐"
        return eventPrompts[randomEvent]!
    }
} 