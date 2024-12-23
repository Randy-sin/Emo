import SwiftUI

extension DayDiary {
    struct MorningEventDescriptionView: View {
        @Environment(\.dismiss) private var dismiss
        let startTime: Date
        let feeling: Int
        let events: [String]
        @State private var eventDescription = ""
        let prompt: DayPrompt
        
        var body: some View {
            VStack {
                // 页面指示器
                HStack {
                    Spacer()
                    Text("3/5")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer()
                    .frame(height: 60)
                
                // 标题
                Text(prompt.descriptionPrompt)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // 描述文本框
                TextEditor(text: $eventDescription)
                    .frame(height: 200)
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                
                Spacer()
                
                // 下一步按钮
                NavigationLink(destination: MorningFutureExpectationView(
                    startTime: startTime,
                    feeling: feeling,
                    events: events,
                    eventDescription: eventDescription,
                    prompt: prompt
                )) {
                    Text("下一步")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(!eventDescription.isEmpty ? Color(red: 0.33, green: 0.33, blue: 0.44) : Color.gray)
                        .cornerRadius(27)
                }
                .disabled(eventDescription.isEmpty)
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
        DayDiary.MorningEventDescriptionView(
            startTime: Date(),
            feeling: 3,
            events: ["运动", "学习"],
            prompt: DayPrompt(
                event: "运动",
                descriptionPrompt: "今天想要通过运动获得什么感受？",
                futurePrompt: "今天的运动计划是什么？",
                expectationPrompt: "期待今天的运动能带来什么改变？"
            )
        )
    }
} 