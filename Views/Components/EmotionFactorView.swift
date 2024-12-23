import SwiftUI

struct EmotionFactorView: View {
    @ObservedObject var viewModel: EmotionViewModel
    let pageIndex: Int
    let totalPages: Int
    
    // 影响因素选项
    private let factors = [
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
    @State private var selectedFactors: Set<String> = []
    @State private var showCustomFactorSheet = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var body: some View {
        VStack(spacing: 0) {
            // 主要内容
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
                        ForEach(factors, id: \.name) { factor in
                            FactorButton(
                                factor: factor,
                                isSelected: selectedFactors.contains(factor.name)
                            ) {
                                toggleFactor(factor.name)
                            }
                        }
                        
                        // 添加自定义因素按钮
                        Button(action: {
                            showCustomFactorSheet = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 30))
                                Text("自定义")
                                    .font(.system(size: 14))
                            }
                            .frame(width: 90, height: 90)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // 底部按钮
            VStack {
                Divider()
                
                Button(action: {
                    viewModel.selectedFactors = selectedFactors
                    viewModel.finishRecording()
                }) {
                    Text("完成")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showCustomFactorSheet) {
            CustomFactorSheet(selectedFactors: $selectedFactors)
        }
    }
    
    private func toggleFactor(_ factor: String) {
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
struct Factor {
    let emoji: String
    let name: String
}

// 因素按钮组件
struct FactorButton: View {
    let factor: Factor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            VStack(spacing: 8) {
                Text(factor.emoji)
                    .font(.system(size: 30))
                Text(factor.name)
                    .font(.system(size: 14))
            }
            .frame(width: 90, height: 90)
            .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// 自定义因素输入表单
struct CustomFactorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFactors: Set<String>
    @State private var customFactor = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("添加自定义影响因素")) {
                    TextField("输入因素名称", text: $customFactor)
                }
            }
            .navigationTitle("自定义因素")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("添加") {
                    if !customFactor.isEmpty {
                        selectedFactors.insert(customFactor)
                        dismiss()
                    }
                }
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