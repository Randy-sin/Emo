import SwiftUI

extension NightDiary {
    struct EventSelectionView: View {
        @Environment(\.dismiss) private var dismiss
        let startTime: Date
        let feeling: Int
        @State private var selectedEvents: Set<String> = []
        @State private var showingCustomEventSheet = false
        @State private var customEmoji = ""
        @State private var customText = ""
        
        // 预设的事件选项
        let predefinedEvents = [
            ("📚", "学习"),
            ("💼", "工作"),
            ("❤️", "朋友"),
            ("💝", "恋人"),
            ("🏠", "家人"),
            ("🍜", "食物"),
            ("🎡", "娱乐"),
            ("🏃", "运动"),
            ("💖", "爱好"),
            ("🌏", "旅行"),
            ("🐶", "宠物")
        ]
        
        var body: some View {
            VStack(spacing: 0) {
                // 页面指示器
                HStack {
                    Spacer()
                    Text("2/5")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // 标题
                Text("今天在什么事情上感觉还算顺利？")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                    .padding(.horizontal, 20)
                
                // 事件网格
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        // 预设事件选项
                        ForEach(predefinedEvents, id: \.1) { emoji, text in
                            EventButton(
                                emoji: emoji,
                                text: text,
                                isSelected: selectedEvents.contains(text)
                            ) {
                                if selectedEvents.contains(text) {
                                    selectedEvents.remove(text)
                                } else {
                                    selectedEvents.insert(text)
                                }
                            }
                        }
                        
                        // 自定义添加按钮
                        Button(action: {
                            showingCustomEventSheet = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                                Text("自定义")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 100, height: 100)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 15)
                }
                
                // 下一步按钮
                NavigationLink(destination: EventDescriptionView(
                    startTime: startTime,
                    feeling: feeling,
                    selectedEvents: selectedEvents,
                    prompt: NightDiary.getRandomPrompt(for: selectedEvents)
                )) {
                    Text("下一步")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(!selectedEvents.isEmpty ? Color(red: 0.33, green: 0.33, blue: 0.44) : Color.gray)
                        .cornerRadius(27)
                }
                .disabled(selectedEvents.isEmpty)
                .simultaneousGesture(TapGesture().onEnded {
                    // 在用户点击下一步时保存第一个选择的事件
                    if let firstEvent = selectedEvents.first,
                       let (emoji, _) = predefinedEvents.first(where: { $0.1 == firstEvent }) {
                        TodayEvent.shared.saveEvent(emoji: emoji, text: firstEvent)
                    }
                })
                .padding(.horizontal, 20)
                .padding(.vertical, 34)
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
            }
            .sheet(isPresented: $showingCustomEventSheet) {
                CustomEventSheet(
                    emoji: $customEmoji,
                    text: $customText,
                    selectedEvents: $selectedEvents,
                    isPresented: $showingCustomEventSheet
                )
            }
        }
    }
    
    // 事件按钮组件
    private struct EventButton: View {
        let emoji: String
        let text: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Text(emoji)
                        .font(.system(size: 32))
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? .black : .primary)
                }
                .frame(width: 100, height: 100)
                .background(isSelected ? Color(red: 0.93, green: 0.87, blue: 0.83) : Color(.systemGray6))
                .cornerRadius(25)
            }
        }
    }
    
    // 自定义事件添加表单
    private struct CustomEventSheet: View {
        @Binding var emoji: String
        @Binding var text: String
        @Binding var selectedEvents: Set<String>
        @Binding var isPresented: Bool
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("添加自定义事件")) {
                        TextField("输入表情符号", text: $emoji)
                        TextField("输入事件描述", text: $text)
                    }
                }
                .navigationTitle("自定义事件")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            isPresented = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("添加") {
                            if !text.isEmpty {
                                selectedEvents.insert(text)
                                isPresented = false
                                emoji = ""
                                text = ""
                            }
                        }
                        .disabled(text.isEmpty)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        NightDiary.EventSelectionView(
            startTime: Date(),
            feeling: 4
        )
    }
} 