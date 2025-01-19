import SwiftUI

struct EmotionFactorView: View {
    @ObservedObject var viewModel: EmotionViewModel
    let pageIndex: Int
    let totalPages: Int
    
    // 影响因素选项
    private let predefinedFactors = [
        Factor(emoji: "📚", name: "学习"),
        Factor(emoji: "💼", name: "工作"),
        Factor(emoji: "💛", name: "朋友"),
        Factor(emoji: "❤️", name: "恋人"),
        Factor(emoji: "🏠", name: "家人"),
        Factor(emoji: "🍲", name: "食物"),
        Factor(emoji: "🎡", name: "娱乐"),
        Factor(emoji: "🏃", name: "运动"),
        Factor(emoji: "🥰", name: "爱好"),
        Factor(emoji: "🌏", name: "旅行"),
        Factor(emoji: "🐶", name: "宠物")
    ]
    
    // 选中的因素
    @State private var selectedFactors: Set<Factor> = []
    @State private var showCustomFactorSheet = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Emoji和情绪类型
                    VStack(spacing: 8) {
                        Text(viewModel.selectedEmotionType?.emoji ?? "")
                            .font(.system(size: 64))
                        
                        Text(viewModel.selectedEmotionType?.rawValue ?? "")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 20)
                    
                    // 问题文字
                    Text("对你影响最大的是？")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.bottom, 10)
                    
                    // 因素网格
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(predefinedFactors) { factor in
                            FactorButton(
                                factor: factor,
                                isSelected: selectedFactors.contains(factor)
                            ) {
                                toggleFactor(factor)
                            }
                        }
                        
                        // 添加自定义因素按钮
                        Button(action: {
                            showCustomFactorSheet = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                Text("自定义")
                                    .font(.system(size: 15))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 90)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1),
                                           radius: 2,
                                           x: 0,
                                           y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(.systemGray5), lineWidth: 0.5)
                            )
                        }
                        
                        // 显示自定义因素
                        ForEach(Array(selectedFactors.filter { $0.isCustom })) { factor in
                            FactorButton(
                                factor: factor,
                                isSelected: true
                            ) {
                                toggleFactor(factor)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // 底部按钮
            VStack {
                Button(action: {
                    viewModel.selectedFactors = Set(selectedFactors.map { $0.name })
                    viewModel.finishRecording()
                }) {
                    Text("完成")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(red: 0.25, green: 0.25, blue: 0.35))
                        .cornerRadius(27)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showCustomFactorSheet) {
            CustomFactorSheet(selectedFactors: $selectedFactors)
        }
    }
    
    private func toggleFactor(_ factor: Factor) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if selectedFactors.contains(factor) {
                selectedFactors.remove(factor)
            } else {
                selectedFactors.insert(factor)
            }
        }
    }
}

// 因素数据模型
struct Factor: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let name: String
    var isCustom: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Factor, rhs: Factor) -> Bool {
        lhs.id == rhs.id
    }
}

// 因素按钮组件
struct FactorButton: View {
    let factor: Factor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(factor.emoji)
                    .font(.system(size: 28))
                Text(factor.name)
                    .font(.system(size: 15))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? 
                        Color(red: 0.25, green: 0.25, blue: 0.35) : 
                        Color(.systemBackground))
                    .shadow(color: Color.black.opacity(isSelected ? 0.2 : 0.1),
                           radius: isSelected ? 4 : 2,
                           x: 0,
                           y: isSelected ? 2 : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 0.5)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
    }
}

// 自定义因素输入表单
struct CustomFactorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFactors: Set<Factor>
    @State private var customFactor = ""
    @State private var selectedEmoji = "🎯"
    
    // 预设的表情选项
    private let emojis = [
        "🎯", "🎨", "🎭", "🎪", "🎫", "🎟️", "🎮", "🎲", "🎳",
        "🎼", "🎹", "🎸", "🎻", "🎺", "🎷", "🥁", "🎤", "🎧",
        "🏋️", "🤸", "🏃", "🚴", "🏊", "⛹️", "🤾", "🤽", "🤺",
        "🎯", "🎱", "🎲", "🎰", "🎳", "🎯", "🎱", "🎪", "🎨"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("选择表情")) {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                            ForEach(emojis, id: \.self) { emoji in
                                Button(action: {
                                    selectedEmoji = emoji
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedEmoji == emoji ? 
                                                Color(red: 0.25, green: 0.25, blue: 0.35) : 
                                                Color(.systemBackground))
                                            .frame(width: 44, height: 44)
                                        
                                        Text(emoji)
                                            .font(.system(size: 24))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 220)
                }
                
                Section(header: Text("输入因素名称")) {
                    TextField("例如: 写作", text: $customFactor)
                }
            }
            .navigationTitle("添加自定义因素")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("添加") {
                    if !customFactor.isEmpty {
                        let newFactor = Factor(emoji: selectedEmoji, 
                                            name: customFactor,
                                            isCustom: true)
                        selectedFactors.insert(newFactor)
                        dismiss()
                    }
                }
                .disabled(customFactor.isEmpty)
            )
        }
    }
}

#Preview {
    EmotionFactorView(
        viewModel: EmotionViewModel(),
        pageIndex: 3,
        totalPages: 4
    )
} 