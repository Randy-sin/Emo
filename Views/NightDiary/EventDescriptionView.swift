import SwiftUI

extension NightDiary {
    struct EventDescriptionView: View {
        @Environment(\.dismiss) private var dismiss
        let startTime: Date
        let feeling: Int
        let selectedEvents: Set<String>
        let prompt: EventPrompt
        @State private var diaryText: String = ""
        
        private var eventsListBold: Text {
            let text = Text(prompt.descriptionPrompt.description)
                .foregroundColor(.secondary)
            return text
        }
        
        var body: some View {
            VStack(spacing: 0) {
                // 页面指示器
                HStack {
                    Spacer()
                    Text("3/5")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // 标题
                Text(prompt.descriptionPrompt.title)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                    .padding(.horizontal, 20)
                
                // 副标题
                eventsListBold
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                
                // 日记输入区域
                TextEditor(text: $diaryText)
                    .font(.system(size: 16))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.top, 30)
                    .padding(.horizontal, 20)
                
                Spacer()
                 
                // 下一步按钮
                NavigationLink(destination: FutureExpectationView(
                    startTime: startTime,
                    feeling: feeling,
                    events: Array(selectedEvents),
                    eventDescription: diaryText.isEmpty ? "无" : diaryText
                )) {
                    Text("下一步")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(red: 0.33, green: 0.33, blue: 0.44))
                        .cornerRadius(27)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
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
        }
    }
}

#Preview {
    NavigationView {
        NightDiary.EventDescriptionView(
            startTime: Date(),
            feeling: 4,
            selectedEvents: ["娱乐", "学习"],
            prompt: NightDiary.eventPrompts["娱乐"]!
        )
    }
} 
