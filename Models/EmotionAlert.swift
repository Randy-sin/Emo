import Foundation
import SwiftUI

struct EmotionAlert {
    struct Suggestion: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let color: Color
        let detail: String?
        let steps: [String]
        let duration: String
        let benefits: String
        
        init(
            title: String,
            icon: String,
            color: Color,
            detail: String? = nil,
            steps: [String] = [],
            duration: String = "",
            benefits: String = ""
        ) {
            self.title = title
            self.icon = icon
            self.color = color
            self.detail = detail
            self.steps = steps
            self.duration = duration
            self.benefits = benefits
        }
    }
    
    enum AlertLevel: Int {
        case normal = 0
        case notice = 1
        case warning = 2
        case serious = 3
        
        var description: String {
            switch self {
            case .normal: return "心情愉悦"
            case .notice: return "轻微情绪波动"
            case .warning: return "情绪需要关注"
            case .serious: return "情绪状态警告"
            }
        }
        
        var gradient: LinearGradient {
            switch self {
            case .normal:
                return LinearGradient(
                    colors: [Color.green.opacity(0.7), Color.mint.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .notice:
                return LinearGradient(
                    colors: [Color.blue.opacity(0.7), Color.cyan.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .warning:
                return LinearGradient(
                    colors: [Color.orange.opacity(0.7), Color.yellow.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .serious:
                return LinearGradient(
                    colors: [Color.red.opacity(0.7), Color.pink.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
        
        var icon: String {
            switch self {
            case .normal: return "sun.max.fill"
            case .notice: return "exclamationmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .serious: return "exclamationmark.shield.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .normal: return .green
            case .notice: return .blue
            case .warning: return .orange
            case .serious: return .red
            }
        }
        
        var subtitle: String {
            switch self {
            case .normal: return "继续保持好心情"
            case .notice: return "让我们一起调节心情"
            case .warning: return "需要更多关注和照顾"
            case .serious: return "建议寻求帮助和支持"
            }
        }
        
        var detailedDescription: String {
            switch self {
            case .normal:
                return "你的心情状态好，希望你能一直保持这样积极乐观的状态。记住，分享快乐能让快乐加倍！"
            case .notice:
                return "最近出现了一些情绪波动，这是很正常的。通过一些简单的方法，我们可以一起让心情变得更好。"
            case .warning:
                return "你最近的情绪似乎有些低落。这时候需要多关注自己的感受，也可以寻求身边人的支持。记住，这样的状态是暂时的，会慢慢好起来的。"
            case .serious:
                return "你的情绪状态需要特别关注。这种时候，除了自我调节，寻求专业的帮助和家人的支持都是很好的选择。你并不孤单，让我们一起度过这个阶段。"
            }
        }
        
        var suggestions: [Suggestion] {
            switch self {
            case .normal:
                return [
                    Suggestion(
                        title: "分享快乐",
                        icon: "heart.circle.fill",
                        color: .pink,
                        detail: "与身边的人分享你的快乐，让快乐加倍",
                        steps: [
                            "1. 找到你信任的朋友或家人",
                            "2. 分享让你开心的事情",
                            "3. 一起回忆和感受快乐时刻",
                            "4. 计划一些有趣的活动"
                        ],
                        duration: "随时进行",
                        benefits: "分享快乐不仅能让自己更开心，也能增进与他人的感情，创造更多美好回忆。"
                    )
                ]
            case .notice, .warning, .serious:
                return []
            }
        }
    }
    
    struct AlertTrigger {
        let consecutiveNegativeEmotions: Int
        let negativeEmotionIntensity: Int
        let timeWindow: TimeInterval
        let minDuration: TimeInterval
    }
    
    static let alertRules: [AlertLevel: AlertTrigger] = [
        .notice: AlertTrigger(
            consecutiveNegativeEmotions: 2,
            negativeEmotionIntensity: 3,
            timeWindow: 24 * 3600,
            minDuration: 2 * 3600
        ),
        .warning: AlertTrigger(
            consecutiveNegativeEmotions: 3,
            negativeEmotionIntensity: 4,
            timeWindow: 24 * 3600,
            minDuration: 4 * 3600
        ),
        .serious: AlertTrigger(
            consecutiveNegativeEmotions: 3,
            negativeEmotionIntensity: 4,
            timeWindow: 24 * 3600,
            minDuration: 8 * 3600
        )
    ]
    
    static func getPersonalizedSuggestions(for type: EmotionType, level: AlertLevel) -> [Suggestion] {
        if type.category == .positive {
            return [
                Suggestion(
                    title: "记录美好时刻",
                    icon: "camera.fill",
                    color: .orange,
                    detail: "拍照或记录下让你开心的瞬间，这些都是珍��的回忆",
                    steps: [
                        "1. 准备一个专门的相册或日记本",
                        "2. 每天记录至少一件让你感到开心或感恩的事",
                        "3. 可以配上照片、文字或简单的涂鸦",
                        "4. 定期回顾这些美好时刻，感受生活的美好"
                    ],
                    duration: "每天5-10分钟",
                    benefits: "通过记录和回顾美好时刻，能够培养积极的心态，增强幸福感，同时也为未来留下珍贵的回忆。"
                ),
                Suggestion(
                    title: "培养兴趣爱好",
                    icon: "heart.fill",
                    color: .pink,
                    detail: "发展一个让你感兴趣的活动，这能让生活更有乐趣",
                    steps: [
                        "1. 列出你感兴趣的活动清单",
                        "2. 选择一个最想尝试的开始",
                        "3. 制定简单的学习计划",
                        "4. 每周安排固定时间练习",
                        "5. 加入相关的兴趣社群，认识志同道合的朋友"
                    ],
                    duration: "每周至少3小时",
                    benefits: "培养兴趣爱好不仅能让生活更加充实，还能认识新朋友，开拓视野，提升自我价值感。"
                ),
                Suggestion(
                    title: "传递正能量",
                    icon: "sparkles",
                    color: .yellow,
                    detail: "用你的快乐感染他人，让世界变得更美好",
                    steps: [
                        "1. 每天对身边的人说一句鼓励的话",
                        "2. 主动帮助需要帮助的人",
                        "3. 分享自己的快乐经历和心得",
                        "4. 参与志愿服务活动",
                        "5. 在社交媒体上分享正能量内容"
                    ],
                    duration: "持续进行，融入日常生活",
                    benefits: "传递正能量不仅能让他人感到温暖，自己也会在这个过程中获得更多快乐和满足感。"
                )
            ]
        }
        
        switch type {
        case .anxious:
            return getAnxiousSuggestions(for: level)
        case .stress:
            return getStressSuggestions(for: level)
        case .angry:
            return getAngrySuggestions(for: level)
        case .tired:
            return getTiredSuggestions(for: level)
        default:
            switch level {
            case .notice:
                return [
                    Suggestion(
                        title: "正念冥想",
                        icon: "brain.head.profile",
                        color: .purple,
                        detail: "找个安静的地方，闭上眼睛，专注于当下的感受",
                        steps: [
                            "1. 找一个安静、舒适的环境",
                            "2. 采用舒适的坐姿，可以盘腿或坐在椅子上",
                            "3. 闭上眼睛，深呼吸三次",
                            "4. 将注意力集中在呼吸上",
                            "5. 如果思绪飘走，温和地把注意力带回呼吸"
                        ],
                        duration: "开始时3-5分钟，熟练后可延长到15-20分钟",
                        benefits: "正念冥想能够帮助你平静心绪，减少负面情绪，提高情绪管理能力。"
                    ),
                    Suggestion(
                        title: "放松身心",
                        icon: "leaf.fill",
                        color: .green,
                        detail: "尝试伸展运动或是泡一杯温暖的花草茶，让身心都放松下来",
                        steps: [
                            "1. 选择一个舒适的姿势，如坐或站",
                            "2. 深呼吸几次，放松身体",
                            "3. 尝试伸展运动，如颈部、肩部、腰部和腿部的拉伸",
                            "4. 喝一杯温暖的花草茶，如薰衣草或洋甘菊茶",
                            "5. 让茶香在空气中弥漫，放松身心"
                        ],
                        duration: "每次5-10分钟",
                        benefits: "通过伸展运动和喝花草茶，可以放松身体，减轻压力，提高睡眠质量。"
                    ),
                    Suggestion(
                        title: "转移注意力",
                        icon: "arrow.triangle.branch",
                        color: .blue,
                        detail: "看一部喜欢的电影或读一本有趣的书，暂时远离烦恼",
                        steps: [
                            "1. 选择一部你感兴趣的电影或一本书",
                            "2. 找一个安静的地方，如家中的沙发或阳台",
                            "3. 开始观看或阅读",
                            "4. 让自己完全沉浸在故事或情节中",
                            "5. 如果思绪飘走，温和地把注意力带回电影或书本"
                        ],
                        duration: "每次15-30分钟",
                        benefits: "通过观看电影或阅读书籍，可以暂时远离烦恼，放松身心，提高情绪管理能力。"
                    )
                ]
            case .warning:
                return []
            case .serious:
                return []
            default:
                return []
            }
        }
    }
    
    static func getSpecificSuggestions(for type: EmotionType, level: AlertLevel) -> [Suggestion] {
        return getPersonalizedSuggestions(for: type, level: level)
    }
    
    private static func getAnxiousSuggestions(for level: AlertLevel) -> [Suggestion] {
        switch level {
        case .notice:
            return [
                Suggestion(
                    title: "呼吸放松",
                    icon: "lungs.fill",
                    color: .blue,
                    detail: "尝试腹式呼吸：将手放在腹部，感受呼吸时腹部的起伏，持续3-5分钟",
                    steps: [
                        "1. 找一个安静的地方，如卧室或客厅",
                        "2. 坐在一个舒适的椅子上或躺在床上",
                        "3. 将一只手放在腹部，感受呼吸时腹部的起伏",
                        "4. 深呼吸几次，感受腹部随着呼吸的扩张和收缩",
                        "5. 保持呼吸节奏，持续3-5分钟"
                    ],
                    duration: "每次3-5分钟",
                    benefits: "通过腹式呼吸，可以放松身体，减轻焦虑和压力，提高专注力和情绪管理能力。"
                ),
                Suggestion(
                    title: "环境调节",
                    icon: "house.fill",
                    color: .green,
                    detail: "调整周围环境，减少可能引起焦虑的因素，创造安静舒适的空间",
                    steps: [
                        "1. 清理房间，保持整洁和舒适",
                        "2. 使用香薰或植物，如薰衣草或洋甘菊，帮助放松和减轻焦虑",
                        "3. 调整室内光线，如使用柔和的灯光或自然光",
                        "4. 保持室内空气流通，如使用空气净化器或开窗通风",
                        "5. 创造一个安静、舒适的环境，如使用隔音材或耳塞"
                    ],
                    duration: "长期坚持",
                    benefits: "通过调整周围环境，减少可能引起焦虑的因素，可以创造一个安静舒适的空间，帮助你放松和减轻焦虑。"
                )
            ]
        case .warning:
            return [
                Suggestion(
                    title: "渐进放松",
                    icon: "figure.mind.and.body",
                    color: .purple,
                    detail: "从脚到头逐步绷紧再放松每组肌肉，每个部位保持5-10秒",
                    steps: [
                        "1. 从脚部开始，逐渐向上移动到头部",
                        "2. 每个部位保持5-10秒，感受肌肉的紧张和放松",
                        "3. 重复多次，直到全身放松"
                    ],
                    duration: "每次5-10秒",
                    benefits: "通过从脚到头逐步绷紧再放松每组肌肉，可以放松身体，减轻焦虑和压力，提高专注力和情绪管理能力。"
                ),
                Suggestion(
                    title: "焦虑分析",
                    icon: "doc.text.magnifyingglass",
                    color: .orange,
                    detail: "写下具体的焦虑源，将大问题分解成小步骤，逐个应对",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始写下具体的焦虑源",
                        "3. 将大问题分解成小步骤",
                        "4. 逐个应对每个小步骤",
                        "5. 定期回顾和分析这些步骤"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过写下具体的焦虑源，将大问题分解成小步骤，逐个应对，可以帮助你更好地管理焦虑，提高解决问题的能力。"
                ),
                Suggestion(
                    title: "接纳练习",
                    icon: "heart.circle.fill",
                    color: .pink,
                    detail: "接纳当下的焦虑感受，提醒自己这是暂时的，不要过分抗拒",
                    steps: [
                        "1. 找一个安静的地方，如卧室或客厅",
                        "2. 找一个舒适的姿势，如坐或躺",
                        "3. 深呼吸几次，放松身体",
                        "4. 感受焦虑的感受，不要抗拒或逃避",
                        "5. 提醒自���这是暂时的，不要过分抗拒"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过接纳当下的焦虑感受，提醒自己这是暂时的，不要过分抗拒，可以帮助你更好地管理焦虑，提高情绪管理能力。"
                )
            ]
        case .serious:
            return [
                Suggestion(
                    title: "专业干预",
                    icon: "cross.case.fill",
                    color: .red,
                    detail: "建议寻求心理医生的帮助，评估是否需要药物治疗或系统性心理治疗",
                    steps: [
                        "1. 寻找一个专业的心理医生或心理咨询师",
                        "2. 预约咨询时间",
                        "3. 在咨询前准备好你的问题和困惑",
                        "4. 在咨询过程中积极倾听和表达",
                        "5. 根据咨询师的建议，考虑是否需要药物治疗或系统性心理治疗"
                    ],
                    duration: "每次50分钟",
                    benefits: "通过专业的心理咨询，你可以获得专业的指导和支持，帮助你更好地管理情绪和心理健康。"
                ),
                Suggestion(
                    title: "全面评估",
                    icon: "clipboard.fill",
                    color: .blue,
                    detail: "记录焦虑发作的频率、强度和具体表现，帮助专业医生更好地诊断",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始记录焦虑发作的频率、强度和具体表现",
                        "3. 每天记录至少一次焦虑发作的情况",
                        "4. 定期回顾和分析这些记录",
                        "5. 根据分析结果，帮助专业医生更好地诊断"
                    ],
                    duration: "每天记录一次",
                    benefits: "通过记录焦虑发作的频率、强度和具体表现，可以帮助专业医生更好地诊断焦虑，提高治疗效果。"
                ),
                Suggestion(
                    title: "支持系统",
                    icon: "person.3.fill",
                    color: .green,
                    detail: "建立紧急联系人清单，在焦虑加重时及时寻求帮助",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始写下紧急联系人清单",
                        "3. 包括家人、朋友或专业人士",
                        "4. 写下他们的联系方式",
                        "5. 定期更新和回顾这个清单"
                    ],
                    duration: "长期坚持",
                    benefits: "通过建立紧急联系人清单，在焦虑加重时及时寻求帮助，可以获得更多的支持和帮助，提高心理韧性。"
                )
            ]
        default:
            return []
        }
    }
    
    private static func getStressSuggestions(for level: AlertLevel) -> [Suggestion] {
        switch level {
        case .notice:
            return [
                Suggestion(
                    title: "微休息",
                    icon: "cup.and.saucer.fill",
                    color: .orange,
                    detail: "每工作1小时休息5-10分钟，活动身体，远离压力源",
                    steps: [
                        "1. 每工作1小时，站起来活动5-10分钟",
                        "2. 做一些简单的伸展运动，如颈部、肩部和腰部的拉伸",
                        "3. 走动或散步，促进血液循环",
                        "4. 喝一杯水或茶，补充水分",
                        "5. 闭上眼睛，放松5-10分钟"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过微休息，可以活动身体，减轻压力，提高工作效率。"
                ),
                Suggestion(
                    title: "舒缓音乐",
                    icon: "music.note",
                    color: .purple,
                    detail: "听些轻柔的音乐，让大脑暂时放空，缓解压力",
                    steps: [
                        "1. 找一个安静的地方，如卧室或客厅",
                        "2. 选择一些轻柔的音乐，如古典音乐或自然声音",
                        "3. 打开音乐播放器或使用音乐软件",
                        "4. 调整音量，让自己感到舒适",
                        "5. 闭上眼睛，放松身体，感受音乐的节奏和旋律"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过听些轻柔的音乐，可以让大脑暂时放空，缓解压力，提高工作效率。"
                )
            ]
        case .warning:
            return [
                Suggestion(
                    title: "压力管理",
                    icon: "list.bullet.clipboard",
                    color: .blue,
                    detail: "列出所有压力源，区分可控和不可控因素，优先处理重要且可控的事务",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始写下所有压力源",
                        "3. 区分可控和不可控因素",
                        "4. 优先处理重要且可控的事务",
                        "5. 定期回顾和调整压力管理策略"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过列出所有压力源，区分可控和不可控因素，优先处理重要且可控的事务，可以帮助你更好地管理压力，提高工作效率。"
                ),
                Suggestion(
                    title: "运动减压",
                    icon: "figure.run",
                    color: .green,
                    detail: "进行30分钟有氧运动，如快走、跑步或游泳，帮助释放压力",
                    steps: [
                        "1. 找一个安静的地方，如健身房或户外",
                        "2. 选择一个有氧运动，如快走、跑步或游泳",
                        "3. 穿上合适的运动装备",
                        "4. 开始运动，保持30分钟",
                        "5. 运动后，感受身体和心情的变化"
                    ],
                    duration: "每次30分钟",
                    benefits: "通过进行30分钟有氧运动，如快走、跑步或游泳，可以帮助你释放压力，提高心情。"
                ),
                Suggestion(
                    title: "时间管理",
                    icon: "clock.badge.checkmark",
                    color: .indigo,
                    detail: "合理规划时间，设定优先级，避免任务堆积造成更大压力",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始规划时间",
                        "3. 设定优先级",
                        "4. 避免任务堆积",
                        "5. 定期回顾和调整时间管理策略"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过合理规划时间，设定优先级，避免任务堆积造成更大压力，可以帮助你更好地管理时间，提高工作效率。"
                )
            ]
        case .serious:
            return [
                Suggestion(
                    title: "生活重整",
                    icon: "arrow.triangle.2.circlepath",
                    color: .purple,
                    detail: "评估当前的生活方式，适当调整工作节奏，必要时考虑请假休整",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始评估当前的生活方式",
                        "3. 考虑适当调整工作节奏",
                        "4. 必要时考虑请假休整",
                        "5. 定期回顾和调整生活节奏"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过评估当前的生活方式，适当调整工作节奏，必要时考虑请假休整，可以帮助你更好地管理生活和工作，提高生活质量。"
                ),
                Suggestion(
                    title: "专业辅导",
                    icon: "person.fill.checkmark",
                    color: .blue,
                    detail: "寻求压力管理专家的帮助，学习科学的压力应对技巧",
                    steps: [
                        "1. 寻找一个专业的压力管理专家或心理咨询师",
                        "2. 预约咨询时间",
                        "3. 在咨询前准备好你的问题和困惑",
                        "4. 在咨询过程中积极倾听和表达",
                        "5. 根据咨询师的建议，学习科学的压力应对技巧"
                    ],
                    duration: "每次50分钟",
                    benefits: "通过寻求压力管理专家的帮助，你可以学习科学的压力应对技巧，帮助你更好地管理压力，提高生活质量。"
                ),
                Suggestion(
                    title: "健康评估",
                    icon: "heart.text.square.fill",
                    color: .red,
                    detail: "关注压力对身体的影响，必要时进行身体检查，预防压力相关疾病",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始记录压力对身体的影响",
                        "3. 注意身体的不适症状",
                        "4. 必要时进行身体检查",
                        "5. 根据医生的建议，采取预防措施"
                    ],
                    duration: "每天记录一次",
                    benefits: "通过关注压力对身体的影响，必要时进行身体检查，可以预防压力相关疾病，提高身体健康。"
                )
            ]
        default:
            return []
        }
    }
    
    private static func getAngrySuggestions(for level: AlertLevel) -> [Suggestion] {
        switch level {
        case .notice:
            return [
                Suggestion(
                    title: "冷静时刻",
                    icon: "snowflake",
                    color: .blue,
                    detail: "深呼吸，慢慢数到10，给自己一个短暂的冷静时间",
                    steps: [
                        "1. 找一个安静的地方，如卧室或客厅",
                        "2. 找一个舒适的姿势，如坐或躺",
                        "3. 深呼吸几次，放松身体",
                        "4. 慢慢数到10，感受呼吸的节奏",
                        "5. 保持静状态，持续5-10秒"
                    ],
                    duration: "每次5-10秒",
                    benefits: "通过深呼吸，慢慢数到10，给自己一个短暂的冷静时间，可以帮助你更好地管理愤怒，提高情绪管理能力。"
                ),
                Suggestion(
                    title: "情绪觉察",
                    icon: "magnifyingglass",
                    color: .purple,
                    detail: "留意愤怒背后的真实感受，可能是受伤、失望或是无助",
                    steps: [
                        "1. 找一个安静的地方，如卧室或客厅",
                        "2. 找一个舒适的姿势，如坐或躺",
                        "3. 深呼吸几次，放松身体",
                        "4. 留意愤怒背后的真实感受",
                        "5. 感受愤怒的感受，不要抗拒或逃避"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过留意愤怒背后的真实感受，可能是受伤、失望或是无助，可以帮助你更好地管理愤怒，提高情绪管理能力。"
                )
            ]
        case .warning:
            return [
                Suggestion(
                    title: "能量释放",
                    icon: "figure.boxing",
                    color: .orange,
                    detail: "通过运动释放情绪，如快走、跑步，或在安全的环境下发泄（如打沙包）",
                    steps: [
                        "1. 找一个安全的环境，如健身房或户外",
                        "2. 选择一个有氧运动，如快走、跑步或打沙包",
                        "3. 穿上合适的运动装备",
                        "4. 开始运动，释放情绪",
                        "5. 运动后，感受身体和心情的变化"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过通过运动释放情绪，如快走、跑步，或在安全的环境下发泄（如打沙包），可以帮助你更好地管理愤怒，提高情绪管理能力。"
                ),
                Suggestion(
                    title: "理性分析",
                    icon: "brain.head.profile",
                    color: .blue,
                    detail: "写下让你生气的事情，尝试从不同角度思考，找到更理性的应对方式",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. ��始写下让你生气的事情",
                        "3. 尝试从不同角度思考",
                        "4. 找到更理性的应对方式",
                        "5. 定期回顾和分析这些事情"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过写下让你生气的事情，尝试从不同角度思考，找到更理性的应对方式，可以帮助你更好地管理愤怒，提高情绪管理能力。"
                ),
                Suggestion(
                    title: "情绪管理",
                    icon: "gauge.with.dots.needle.bottom.50percent",
                    color: .green,
                    detail: "学习情绪管理技巧，识别愤怒的早期信号，及时调整",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始学习情绪管理技巧",
                        "3. 识别愤怒的早期信号",
                        "4. 及时调整情绪",
                        "5. 定期回顾和调整情绪管理策略"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过学习情绪管理技巧，识别愤怒的早期信号，及时调整，可以帮助你更好地管理愤怒，提高情绪管理能力。"
                )
            ]
        case .serious:
            return [
                Suggestion(
                    title: "专业指导",
                    icon: "person.fill.questionmark",
                    color: .blue,
                    detail: "寻求心理咨询师的帮助，学习更有效的愤怒管理方法",
                    steps: [
                        "1. 找一个专业的心理咨询师或心理医生",
                        "2. 预约咨询时间",
                        "3. 在咨询前准备好你的问题和困惑",
                        "4. 在咨询过程中积极倾听和表达",
                        "5. 根据咨询师的建议，学习更有效的愤怒管理方法"
                    ],
                    duration: "每次50分钟",
                    benefits: "通过寻求心理咨询师的帮助，你可以学习更有效的愤怒管理方法，帮助你更好地管理愤怒，提高情绪管理能力。"
                ),
                Suggestion(
                    title: "沟通技巧",
                    icon: "bubble.left.and.bubble.right.fill",
                    color: .green,
                    detail: "学习有效的沟通方式，用'我的感受'来表达，避免指责性语言",
                    steps: [
                        "1. 找一个安静的地方，如卧室或客厅",
                        "2. 开始学习有效的沟通方式",
                        "3. 用'我的感受'来表达",
                        "4. 避免指责性语言",
                        "5. 定期回顾和调整沟通技巧"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过学习有效的沟通方式，用'我的感受'来表达，避免指责性语言，可以帮助你更好地管理愤怒，提高情绪管理能力。"
                ),
                Suggestion(
                    title: "预防计划",
                    icon: "shield.lefthalf.filled",
                    color: .purple,
                    detail: "制定愤怒预防计划，包括识别触发因素、警示信号和应对策略",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始制定愤怒预防计划",
                        "3. 识别触发因素",
                        "4. 制定警示信号",
                        "5. 制定应对策略"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过制定愤怒预防计划，包括识别触发因素、警示信号和应对策略，可以帮助你更好地管理愤怒，提高情绪管理能力。"
                )
            ]
        default:
            return []
        }
    }
    
    private static func getTiredSuggestions(for level: AlertLevel) -> [Suggestion] {
        switch level {
        case .notice:
            return [
                Suggestion(
                    title: "小憩放松",
                    icon: "bed.double.fill",
                    color: .blue,
                    detail: "找时间小睡15-20分钟，但避免睡太久影响晚上的睡眠",
                    steps: [
                        "1. 找一个安静的地方，如卧室或客厅",
                        "2. 找一个舒适的姿势，如侧卧或仰卧",
                        "3. 闭上眼睛，放松身体",
                        "4. 小睡15-20分钟",
                        "5. 避免睡太久影响晚上的睡眠"
                    ],
                    duration: "每次15-20分钟",
                    benefits: "通过小憩放松，可以补充能量，提高工作效率，同时避免影响晚上的睡眠。"
                ),
                Suggestion(
                    title: "能量补充",
                    icon: "leaf.fill",
                    color: .green,
                    detail: "适当补充水分和营养，选择健康的零食提供能量",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始记录你的能量补充计划",
                        "3. 适当补充水分和营养",
                        "4. 选择健康的零食提供能量",
                        "5. 定期回顾和调整能量补充策略"
                    ],
                    duration: "每天补充一次",
                    benefits: "通过适当补充水分和营养，选择健康的零食提供能量，可以帮助你更好地管理疲劳，提高工作效率。"
                )
            ]
        case .warning:
            return [
                Suggestion(
                    title: "作息调整",
                    icon: "clock.fill",
                    color: .orange,
                    detail: "检查最近的作息是否规律，调整睡眠时间，保证7-8小时的充足睡眠",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始记录你的作息时间",
                        "3. 检查最近的作息是否规律",
                        "4. 调整睡眠时间",
                        "5. 保证7-8小时的充足睡眠"
                    ],
                    duration: "每天记录一次",
                    benefits: "通过检查最近的作息是否规律，调整睡眠时间，保证7-8小时的充足睡眠，可以帮助你更好地管理疲劳，提高睡眠质量。"
                ),
                Suggestion(
                    title: "运动活力",
                    icon: "figure.walk",
                    color: .green,
                    detail: "进行适度的运动，如散步或伸展，促进血液循环，提升能量",
                    steps: [
                        "1. 找一个安静的地方，如卧室或客厅",
                        "2. 开始进行适度的运动",
                        "3. 进行散步或伸展",
                        "4. 促进血液循环",
                        "5. 提升能量"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过进行适度的运动，如散步或伸展，可以促进血液循环，提升能量，帮助你更好地管理疲劳，提高工作效率。"
                ),
                Suggestion(
                    title: "环境优化",
                    icon: "sun.max.fill",
                    color: .yellow,
                    detail: "确保工作环境通风良好，适当接触自然光，提升精神状态",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始记录你的工作环境",
                        "3. 确保工作环境通风良好",
                        "4. 适当接触自然光",
                        "5. 提升精神状态"
                    ],
                    duration: "每天记录一次",
                    benefits: "通过确保工作环境通风良好，适当接触自然光，可以提升精神状态，帮助你更好地管理疲劳，提高工作效率。"
                )
            ]
        case .serious:
            return [
                Suggestion(
                    title: "健康检查",
                    icon: "heart.text.square.fill",
                    color: .red,
                    detail: "持续疲劳可能与身体状况有关，建议进行健康检查",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始记录你的疲劳情况",
                        "3. 注意身体的不适症状",
                        "4. ��要时进行健康检查",
                        "5. 根据医生的建议，采取改善措施"
                    ],
                    duration: "每天记录一次",
                    benefits: "通过持续记录疲劳情况，必要时进行健康检查，可以帮助你更好地管理疲劳，提高身体健康。"
                ),
                Suggestion(
                    title: "生活评估",
                    icon: "chart.bar.fill",
                    color: .blue,
                    detail: "评估工作和生活的平衡，必要时调整节奏，避免过度劳累",
                    steps: [
                        "1. 找一个安静的地方，如书桌或笔记本",
                        "2. 开始评估你的工作和生活的平衡",
                        "3. 考虑适当调整工作节奏",
                        "4. 必要时调整节奏",
                        "5. 避免过度劳累"
                    ],
                    duration: "每次5-10分钟",
                    benefits: "通过评估工作和生活的平衡，必要时调整节奏，避免过度劳累，可以帮助你更好地管理疲劳，提高生活质量。"
                ),
                Suggestion(
                    title: "专业建议",
                    icon: "person.fill.checkmark",
                    color: .green,
                    detail: "咨询医生或营养师获取改善体能和精力的专业建议",
                    steps: [
                        "1. 找一个专业的心理咨询师或营养师",
                        "2. 预约咨询时间",
                        "3. 在咨询前准备好你的问题和困惑",
                        "4. 在咨询过程中积极倾听和表达",
                        "5. 根据咨询师的建议，获取改善体能和精力的专业建议"
                    ],
                    duration: "每次50分钟",
                    benefits: "通过咨询医生或营养师，你可以获取改善体能和精力的专业建议，帮助你更好地管理疲劳，提高生活质量。"
                )
            ]
        default:
            return []
        }
    }
} 