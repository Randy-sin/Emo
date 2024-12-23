# EmoEase - 情绪记录与放松引导应用

EmoEase 是一款简单而实用的 iOS 情绪记录应用，帮助用户追踪日常情绪变化，并通过呼吸引导提供即时的放松体验。

## 功能特点

- 📝 **快速情绪记录**：通过简单的表情选择完成情绪记录
- 🧘‍♂️ **呼吸引导**：记录完成后提供简短的呼吸动画，帮助放松
- 📊 **历史记录**：查看过去7天的情绪记录
- 📈 **数据统计**：直观显示情绪出现频率
- 💾 **本地存储**：所有数据安全存储在设备本地

## 技术架构

- **开发语言**：Swift
- **UI框架**：SwiftUI
- **架构模式**：MVVM
- **数据存储**：UserDefaults
- **最低支持系统**：iOS 14.0+

## 项目结构

```
EmoEase/
├── Models/
│   └── EmotionRecord.swift     # 数据模型与存储逻辑
├── Views/
│   ├── HomeView.swift          # 主页面视图
│   └── HistoryView.swift       # 历史记录视图
├── ViewModels/
│   └── EmotionViewModel.swift  # 视图模型
└── EmoEaseApp.swift           # 应用入口
```

## 主要组件

### Models
- `EmotionRecord`: 情绪记录数据模型
- `EmotionStorage`: 数据持久化管理器

### Views
- `HomeView`: 情绪记录主界面
- `HistoryView`: 历史记录查看界面
- `BreathingAnimationView`: 呼吸动画组件

### ViewModels
- `EmotionViewModel`: 管理情绪记录的业务逻辑

## 开发环境要求

- Xcode 12.0+
- iOS 17.0+
- Swift 5.0+

## 安装与运行

1. 克隆项目到本地
2. 使用 Xcode 打开项目
3. 选择目标设备或模拟器
4. 点击运行按钮或按下 `Cmd + R`

## 使用说明

1. 打开应用，在"记录"标签页选择当前的情绪状态
2. 选择后会显示呼吸动画，跟随动画进行放松
3. 在"历史"标签页查看过往记录和统计信息

## 后续开发计划

- [ ] 添加更多情绪类型
- [ ] 支持自定义呼吸引导时长
- [ ] 添加详细的情绪分析报告
- [ ] 支持数据导出功能
- [ ] 添加主题切换功能
- [ ] 集成通知提醒功能

## 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进项目。

## 许可证

MIT License
