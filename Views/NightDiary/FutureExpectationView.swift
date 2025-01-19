import SwiftUI

extension NightDiary {
    struct FutureExpectationView: View {
        @Environment(\.dismiss) private var dismiss
        @State private var text = ""
        let startTime: Date
        let feeling: Int
        let events: [String]
        let eventDescription: String
        
        var body: some View {
            VStack(spacing: 0) {
                // 页面指示器
                HStack {
                    Spacer()
                    Text("5/5")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // 标题
                Text("期待明天发生什么美好的事情")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                    .padding(.horizontal, 20)
                
                // 文本编辑器
                TextEditor(text: $text)
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 30)
                
                Spacer()
                
                // 下一步按钮
                NavigationLink(destination: CompletionView(
                    startTime: startTime,
                    feeling: feeling,
                    events: events,
                    eventDescription: eventDescription,
                    futureExpectation: text.isEmpty ? "无" : text
                )) {
                    Text("下一步")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(red: 0.33, green: 0.33, blue: 0.44))
                        .cornerRadius(27)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    // 保存日记记录
                    NightDiaryRecord.shared.saveRecord(
                        startTime: startTime,
                        feeling: feeling,
                        events: events,
                        eventDescription: eventDescription,
                        futureExpectation: text.isEmpty ? "无" : text
                    )
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
        }
    }
}

#Preview {
    NavigationView {
        NightDiary.FutureExpectationView(
            startTime: Date(),
            feeling: 0,
            events: [],
            eventDescription: ""
        )
    }
} 