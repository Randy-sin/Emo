import SwiftUI

/// Main Interface
struct ContentView: View {
    @State private var isShowingGuide = true  // 默认显示引导页
    @State private var showGuideButton = false  // 显示重新打开引导的按钮
    @StateObject private var visionProcessor = VisionProcessor()
    
    var body: some View {
        ZStack {
            CameraView()
                .edgesIgnoringSafeArea(.all)
                .environmentObject(visionProcessor)
            
            VStack {
                // Top guidance text
                HStack {
                    Text("Face the camera directly\nDon't tilt your head")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    if showGuideButton {
                        Button(action: {
                            withAnimation {
                                isShowingGuide = true
                            }
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Bottom smile detection status
                VStack(spacing: 10) {
                    Text(visionProcessor.isSmiling ? "Great Smile! 😊" : "Show your teeth and smile big! 😐")
                        .font(.headline)
                        .padding()
                        .background(visionProcessor.isSmiling ? Color.green.opacity(0.8) : Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    if !visionProcessor.isSmiling {
                        Text("Tips: Keep your head straight and show your teeth")
                            .font(.subheadline)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 50)
                
                // 微笑进度指示器
                ZStack {
                    // 背景圆环
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 6)
                        .frame(width: 80, height: 80)
                    
                    // 进度圆环
                    Circle()
                        .trim(from: 0, to: min(CGFloat(visionProcessor.smilingDuration / 3.0), 1.0))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    // 中间的文本
                    if visionProcessor.hasReachedTarget {
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text(String(format: "%.1f", max(3.0 - visionProcessor.smilingDuration, 0)))
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 50)
                
                // 帮助按钮
                Button(action: {
                    isShowingGuide = true
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(.bottom, 30)
            }
            
            // 引导页覆盖层
            if isShowingGuide {
                GuideView(isShowingGuide: $isShowingGuide)
                    .transition(.opacity)
                    .onDisappear {
                        showGuideButton = true
                    }
            }
        }
        .onAppear {
            // Force landscape orientation
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
}
