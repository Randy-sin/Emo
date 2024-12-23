import Foundation

extension DayDiary {
    struct MorningEventsPrompts {
        static let prompts: [String: DayPrompt] = [
            "学习": DayPrompt(
                event: "学习",
                descriptionPrompt: "今天想要学习什么？",
                futurePrompt: "有什么学习计划吗？",
                expectationPrompt: "期待能学到什么？"
            ),
            "工作": DayPrompt(
                event: "工作",
                descriptionPrompt: "今天有什么工作任务？",
                futurePrompt: "工作上有什么目标？",
                expectationPrompt: "希望能完成什么？"
            ),
            "朋友": DayPrompt(
                event: "朋友",
                descriptionPrompt: "今天想和朋友做什么？",
                futurePrompt: "有什么约定吗？",
                expectationPrompt: "期待能有什么美好时光？"
            ),
            "恋人": DayPrompt(
                event: "恋人",
                descriptionPrompt: "今天想和Ta做什么？",
                futurePrompt: "有什么浪漫计划吗？",
                expectationPrompt: "期待能创造什么美好回忆？"
            ),
            "家人": DayPrompt(
                event: "家人",
                descriptionPrompt: "今天想和家人做什么？",
                futurePrompt: "有什么家庭活动吗？",
                expectationPrompt: "期待能有什么温馨时刻？"
            ),
            "食物": DayPrompt(
                event: "食物",
                descriptionPrompt: "今天想吃什么美食？",
                futurePrompt: "有什么饮食计划吗？",
                expectationPrompt: "期待能品尝到什么？"
            ),
            "娱乐": DayPrompt(
                event: "娱乐",
                descriptionPrompt: "今天想玩什么？",
                futurePrompt: "有什么娱乐计划吗？",
                expectationPrompt: "期待能获得什么快乐？"
            ),
            "运动": DayPrompt(
                event: "运动",
                descriptionPrompt: "今天想做什么运动？",
                futurePrompt: "有什么运动计划吗？",
                expectationPrompt: "期待能达到什么目标？"
            ),
            "爱好": DayPrompt(
                event: "爱好",
                descriptionPrompt: "今天想培养什么爱好？",
                futurePrompt: "有什么特别计划吗？",
                expectationPrompt: "期待能有什么收获？"
            ),
            "旅行": DayPrompt(
                event: "旅行",
                descriptionPrompt: "今天想去哪里？",
                futurePrompt: "有什么旅行计划吗？",
                expectationPrompt: "期待能看到什么风景？"
            ),
            "宠物": DayPrompt(
                event: "宠物",
                descriptionPrompt: "今天想和宠物做什么？",
                futurePrompt: "有什么互动计划吗？",
                expectationPrompt: "期待能有什么温馨时刻？"
            )
        ]
        
        static func getPrompt(for event: String) -> DayPrompt {
            return prompts[event] ?? DayPrompt(
                event: event,
                descriptionPrompt: "今天想要通过\(event)获得什么感受？",
                futurePrompt: "今天关于\(event)的计划是什么？",
                expectationPrompt: "期待\(event)能带来什么改变？"
            )
        }
    }
} 