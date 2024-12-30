import SwiftUI

struct GuideView: View {
    @Binding var isShowingGuide: Bool
    
    var body: some View {
        ZStack {
            // 半透明黑色背景
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("How to Take a Perfect Smile Photo")
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // 示例图片
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                        
                        Text("Face the camera\ndirectly and smile")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .font(.callout)
                    }
                }
                
                // 指导步骤
                VStack(alignment: .leading, spacing: 20) {
                    GuideStep(number: 1, text: "Face the camera directly")
                    GuideStep(number: 2, text: "Keep your head straight, don't tilt")
                    GuideStep(number: 3, text: "Show your teeth while smiling")
                    GuideStep(number: 4, text: "Make a big natural smile")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                
                Button(action: {
                    withAnimation {
                        isShowingGuide = false
                    }
                }) {
                    Text("Got it!")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 200)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding(30)
        }
    }
}

// 引导步骤组件
struct GuideStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                Text("\(number)")
                    .foregroundColor(.black)
                    .font(.headline)
            }
            Text(text)
                .foregroundColor(.white)
                .font(.body)
        }
    }
} 