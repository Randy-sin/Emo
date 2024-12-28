import SwiftUI

struct EmotionAlertView: View {
    let alertLevel: EmotionAlert.AlertLevel
    let suggestions: [EmotionAlert.Suggestion]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 预警标题栏
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 16) {
                    // 图标容器
                    Circle()
                        .fill(alertLevel.gradient)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: alertLevel.icon)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        )
                        .shadow(color: alertLevel.color.opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    // 文字信息
                    VStack(alignment: .leading, spacing: 4) {
                        Text(alertLevel.description)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(alertLevel.subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 展开/收起箭头
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 20))
                        .imageScale(.medium)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            }
            
            // 建议内容
            if isExpanded {
                VStack(alignment: .leading, spacing: 20) {
                    // 通用建议
                    VStack(alignment: .leading, spacing: 16) {
                        Text("建议")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        ForEach(alertLevel.suggestions) { suggestion in
                            SuggestionRow(suggestion: suggestion)
                        }
                    }
                    
                    // 具体建议列表
                    if !suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("个性化建议")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            ForEach(suggestions) { suggestion in
                                SuggestionRow(suggestion: suggestion)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.top, 16)
            }
        }
        .padding(.horizontal)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
    }
}

// 建议行视图
struct SuggestionRow: View {
    let suggestion: EmotionAlert.Suggestion
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Circle()
                .fill(suggestion.color.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: suggestion.icon)
                        .foregroundColor(suggestion.color)
                        .font(.system(size: 14))
                )
            
            // 文字
            Text(suggestion.title)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
} 