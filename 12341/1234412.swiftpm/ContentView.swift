import SwiftUI

/// Main Interface
struct ContentView: View {
    @State private var isSmiling = false
    @State private var isShowingGuide = true  // 默认显示引导页
    @State private var showGuideButton = false  // 显示重新打开引导的按钮
    
    var body: some View {
        ZStack {
            CameraView()
                .edgesIgnoringSafeArea(.all)
            
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
                    Text(isSmiling ? "Great Smile! 😊" : "Show your teeth and smile big! 😐")
                        .font(.headline)
                        .padding()
                        .background(isSmiling ? Color.green.opacity(0.8) : Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    if !isSmiling {
                        Text("Tips: Keep your head straight and show your teeth")
                            .font(.subheadline)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 50)
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
            setupSmileDetectionObserver()
            // Force landscape orientation
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    private func setupSmileDetectionObserver() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("SmileDetected"),
            object: nil,
            queue: .main
        ) { notification in
            if let isSmiling = notification.userInfo?["isSmiling"] as? Bool {
                Task { @MainActor in
                    self.isSmiling = isSmiling
                }
            }
        }
    }
}
