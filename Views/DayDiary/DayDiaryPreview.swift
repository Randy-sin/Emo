import SwiftUI

struct DayDiaryPreview: View {
    @Environment(\.dismiss) private var dismiss
    let record: DayDiaryRecord.Record?
    @State private var showingActionSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题
            Text("早安·元气满满")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 40)
            
            // 信息区域
            HStack(spacing: 0) {
                // 日记类型
                VStack(spacing: 4) {
                    Text("日记类型")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("早安日记")
                        .font(.system(size: 15))
                }
                .frame(maxWidth: .infinity)
                
                // 创建时间
                VStack(spacing: 4) {
                    Text("创建时间")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(record?.startTime.formatted(date: .omitted, time: .shortened) ?? "--:--")
                        .font(.system(size: 15))
                }
                .frame(maxWidth: .infinity)
                
                // 正念时长
                VStack(spacing: 4) {
                    Text("正念时长")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(record != nil ? formatDuration(record!.duration) : "--")
                        .font(.system(size: 15))
                }
                .frame(maxWidth: .infinity)
                
                // 正念字数
                VStack(spacing: 4) {
                    Text("正念字数")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(record != nil ? "\(record!.wordCount)" : "--")
                        .font(.system(size: 15))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 30)
            
            // 分隔线
            HStack {
                ForEach(0..<50) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 4, height: 1)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 1)
                }
            }
            .padding(.top, 30)
            
            // 内容预览
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 1. 今日感受
                    VStack(alignment: .leading, spacing: 8) {
                        Text("今日感受")
                            .font(.system(size: 17, weight: .medium))
                        Text(record != nil ? "感觉程度：\(record!.feeling)/5" : "--")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    
                    // 2. 期待事件
                    VStack(alignment: .leading, spacing: 8) {
                        Text("期待事件")
                            .font(.system(size: 17, weight: .medium))
                        Text(record != nil ? record!.events.joined(separator: "、") : "--")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    
                    // 3. 事件描述
                    VStack(alignment: .leading, spacing: 8) {
                        Text("事件描述")
                            .font(.system(size: 17, weight: .medium))
                        Text(record?.eventDescription ?? "--")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    
                    // 4. 未来期待
                    VStack(alignment: .leading, spacing: 8) {
                        Text("未来期待")
                            .font(.system(size: 17, weight: .medium))
                        Text(record?.futureExpectation ?? "--")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 17, weight: .medium))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingActionSheet = true
                }) {
                    Text("更多")
                        .foregroundColor(.gray)
                        .font(.system(size: 17))
                }
            }
        }
        .confirmationDialog("选择操作", isPresented: $showingActionSheet, titleVisibility: .hidden) {
            Button("删除", role: .destructive) {
                // 删除记录
                DayDiaryRecord.shared.clearCurrentRecord()
                // 清除完成状态
                MorningCompletionRecord.shared.clearTodayCompletion()
                // 关闭预览
                dismiss()
                // 延迟一小段时间后发送通知，确保视图已经关闭
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // 发送通知更新主页状态
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ResetHomeView"),
                        object: nil
                    )
                }
            }
            
            Button("取消", role: .cancel) {}
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        if minutes < 1 {
            return "不到1分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
}

#Preview {
    NavigationView {
        DayDiaryPreview(record: DayDiaryRecord.Record(
            startTime: Date().addingTimeInterval(-300),
            feeling: 4,
            events: ["运动", "学习"],
            eventDescription: "今天准备好好运动和学习",
            futureExpectation: "希望今天能保持这样的状态"
        ))
    }
} 