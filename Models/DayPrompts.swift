import Foundation

struct DayPrompt {
    let event: String
    let descriptionPrompt: String
    let futurePrompt: String
    let expectationPrompt: String
}

let dayPrompts: [String: DayPrompt] = [
    "娱乐": DayPrompt(
        event: "娱乐",
        descriptionPrompt: "今天想要通过娱乐获得什么样的快乐？",
        futurePrompt: "今天的娱乐计划是什么？",
        expectationPrompt: "期待今天的娱乐能带来什么样的惊喜？"
    ),
    "学习": DayPrompt(
        event: "学习",
        descriptionPrompt: "今天想要学习什么新知识？",
        futurePrompt: "今天的学习目标是什么？",
        expectationPrompt: "期待今天的学习能有什么收获？"
    ),
    "工作": DayPrompt(
        event: "工作",
        descriptionPrompt: "今天想要在工作中实现什么目标？",
        futurePrompt: "今天的工作重点是什么？",
        expectationPrompt: "期待今天的工作能有什么突破？"
    ),
    "运动": DayPrompt(
        event: "运动",
        descriptionPrompt: "今天想要通过运动获得什��感受？",
        futurePrompt: "今天的运动计划是什么？",
        expectationPrompt: "期待今天的运动能带来什么改变？"
    )
]

func getRandomDayPrompt(for events: Set<String>) -> DayPrompt? {
    let availablePrompts = events.compactMap { dayPrompts[$0] }
    return availablePrompts.randomElement()
} 