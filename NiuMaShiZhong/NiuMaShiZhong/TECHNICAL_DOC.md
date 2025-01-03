# 技术文档

## 系统架构

### 技术栈
- 开发框架：SwiftUI
- 最低支持版本：iOS 15.0
- 开发语言：Swift 5.9
- 数据持久化：UserDefaults
- 本地化支持：Localizable.strings

### 核心模块

#### 1. 数据模型 (Models)
```swift
struct WorkConfig: Codable {
    var monthlySalary: Double
    var workStartTime: Date
    var workEndTime: Date
    var workSchedule: WorkSchedule
    var joinDate: Date
}
```

#### 2. 视图层 (Views)
- ContentView：主视图
- InfoCard：信息展示卡片
- TimeCard：时间显示卡片
- EarningsCard：收入展示卡片
- ConfigView：配置视图

#### 3. 工具类 (Utils)
- 时间计算器
- 收入计算器
- 本地化管理器

## 核心功能实现

### 1. 实时收入计算
- 基于工作时间计算当前收入
- 支持多种工作制度（双休、单休、大小周）
- 精确到秒级别的收入统计

### 2. 时间管理
- 实时时钟显示
- 倒计时功能
- 工作时间追踪

### 3. 数据持久化
- 使用 UserDefaults 存储配置
- 支持数据编码解码
- 本地数据管理

### 4. 界面设计
- 支持浅色/深色模式
- 自适应布局
- 流畅动画效果

## 性能优化

### 1. 内存管理
- 避免内存泄漏
- 及时释放资源
- 优化数据结构

### 2. 渲染性能
- 减少不必要的视图更新
- 优化动画性能
- 使用懒加载技术

### 3. 计算优化
- 缓存计算结果
- 优化计算逻辑
- 减少不必要的重复计算

## 本地化支持

### 支持语言
- 简体中文
- English

### 本地化文件
- Localizable.strings
- InfoPlist.strings

## 测试策略

### 单元测试
- 模型测试
- 工具类测试
- 计算逻辑测试

### UI 测试
- 界面交互测试
- 动画效果测试
- 适配性测试

## 部署要求

### 系统要求
- iOS 15.0 或更高版本
- 支持 iPhone 和 iPad

### 设备兼容性
- 支持所有 iPhone 机型
- 支持所有 iPad 机型
- 针对不同设备优化布局

## 开发环境

### 工具要求
- Xcode 15.0+
- iOS SDK 15.0+
- Swift 5.9+

### 构建说明
1. 克隆项目代码
2. 打开 Xcode 项目
3. 选择目标设备
4. 构建并运行

## 代码规范

### 命名规范
- 使用驼峰命名法
- 类名首字母大写
- 方法名使用动词开头

### 文件组织
- 按功能模块分组
- 清晰的文件命名
- 合理的目录结构

## 版本控制

### Git 规范
- 使用 feature 分支开发
- commit 信息规范
- 版本号管理

### 发布流程
1. 代码审查
2. 测试验证
3. 版本打包
4. 提交 App Store 