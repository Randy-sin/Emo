# 牛马时钟 - iOS前端开发指南

## 1. 技术栈选择

### 1.1 核心框架
- SwiftUI：用于构建现代化的用户界面
- Combine：用于响应式编程和数据流管理
- WidgetKit：用于开发主屏幕小组件

### 1.2 状态管理
- SwiftUI的@State和@Binding：用于视图内部状态管理
- @StateObject和@ObservedObject：用于跨视图状态共享
- @EnvironmentObject：用于全局状态管理

## 2. 项目结构

### 2.1 目录组织
```
NiuMaShiZhong/                # 主项目目录
├── NiuMaShiZhongApp.swift    # 应用入口
├── ContentView.swift         # 主视图
├── Views/                    # 视图组件
├── Models/                   # 数据模型
├── Shared/                   # 共享代码
├── Resources/                # 资源文件
│   └── Localizable.strings   # 本地化文件
├── Assets.xcassets/          # 图片资源
└── Preview Content/          # 预览资源

WidgetForNiuMa/              # Widget 扩展
├── WidgetForNiuMa.swift     # Widget主要实现
├── WidgetForNiuMaControl.swift # Widget控制器
├── WidgetForNiuMaBundle.swift # Widget包
├── Extensions.swift         # 扩展方法
├── Info.plist               # 配置文件
└── Assets.xcassets/         # Widget资源

NiuMaShiZhongTests/          # 单元测试
└── ...

NiuMaShiZhongUITests/        # UI测试
└── ...
```

### 2.2 模块职责
- NiuMaShiZhongApp.swift: 应用程序入口点，配置应用程序级别的设置
- ContentView.swift: 主视图容器，管理主要的视图层级
- Views/: 包含所有自定义视图组件和页面
- Models/: 数据模型和业务逻辑
- Shared/: 在主应用和Widget之间共享的代码
- Resources/: 本地化文件和其他资源
- WidgetForNiuMa/: 实现主屏幕小组件功能

## 3. 代码规范

### 3.1 命名规范
- 文件命名：大驼峰命名法（PascalCase）
  ```swift
  HomeView.swift
  WorkConfigModel.swift
  ```
- 变量命名：小驼峰命名法（camelCase）
  ```swift
  var userName: String
  let workingHours: Int
  ```
- 常量命名：大写下划线（UPPER_SNAKE_CASE）
  ```swift
  let MAX_WORK_HOURS = 8
  let DEFAULT_SALARY = 5000
  ```

### 3.2 代码格式化
- 使用SwiftFormat进行代码格式化
- 缩进使用4个空格
- 大括号新起一行
- 方法之间空一行
- 相关属性分组放置

### 3.3 注释规范
```swift
/// 视图描述
/// - Parameters:
///   - param1: 参数1描述
///   - param2: 参数2描述
/// - Returns: 返回值描述
func someFunction(param1: String, param2: Int) -> Bool {
    // 实现细节注释
    return true
}
```

## 4. UI组件规范

### 4.1 基础组件
```swift
// 按钮样式
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}

// 卡片样式
struct InfoCard: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}
```

### 4.2 颜色规范
```swift
extension Color {
    static let primary = Color("PrimaryColor")
    static let secondary = Color("SecondaryColor")
    static let background = Color("BackgroundColor")
    static let text = Color("TextColor")
}
```

### 4.3 字体规范
```swift
extension Font {
    static let titleLarge = Font.system(size: 28, weight: .bold)
    static let titleMedium = Font.system(size: 20, weight: .semibold)
    static let bodyRegular = Font.system(size: 16, weight: .regular)
    static let captionSmall = Font.system(size: 12, weight: .regular)
}
```

## 5. 状态管理

### 5.1 视图状态
```swift
class HomeViewModel: ObservableObject {
    @Published var currentIncome: Double = 0
    @Published var workingStatus: WorkingStatus = .notWorking
    
    // 状态更新方法
    func updateIncome() {
        // 实现收入更新逻辑
    }
}
```

### 5.2 全局状态
```swift
class AppState: ObservableObject {
    @Published var userConfig: WorkConfig
    @Published var currentTheme: Theme
    
    // 全局状态管理方法
    func updateConfig(_ newConfig: WorkConfig) {
        // 实现配置更新逻辑
    }
}
```

## 6. 性能优化

### 6.1 视图优化
- 使用`@ViewBuilder`优化条件渲染
- 适当使用`LazyVStack`和`LazyHStack`
- 大列表使用`List`而不是`ScrollView`
- 使用`Group`组织复杂视图

### 6.2 数据优化
- 使用`Combine`处理异步操作
- 合理使用`@StateObject`和`@ObservedObject`
- 避免频繁的状态更新
- 实现必要的记忆化（Memoization）

## 7. 测试规范

### 7.1 单元测试
```swift
class CalculatorTests: XCTestCase {
    func testIncomeCalculation() {
        let calculator = IncomeCalculator()
        let result = calculator.calculateDailyIncome(salary: 10000)
        XCTAssertEqual(result, 476.19, accuracy: 0.01)
    }
}
```

### 7.2 UI测试
```swift
class ViewTests: XCTestCase {
    func testHomeViewDisplay() {
        let view = HomeView()
        let controller = UIHostingController(rootView: view)
        XCTAssertNotNil(controller.view)
    }
}
```

## 8. 发布规范

### 8.1 版本控制
- 使用语义化版本号（Semantic Versioning）
- 每个版本都要有清晰的更新日志
- 重要更新需要添加迁移指南

### 8.2 代码审查
- 提交前进行代码自审
- 遵循团队约定的PR模板
- 确保所有测试通过
- 检查代码覆盖率

## 9. 最佳实践

### 9.1 架构原则
- 遵循SOLID原则
- 保持视图的纯函数特性
- 业务逻辑下沉到ViewModel
- 使用依赖注入管理服务

### 9.2 性能原则
- 避免过度使用计算属性
- 合理使用异步操作
- 优化视图层级结构
- 注意内存泄漏问题

### 9.3 安全原则
- 敏感数据加密存储
- 使用KeyChain存储关键信息
- 实现数据备份机制
- 注意权限管理 