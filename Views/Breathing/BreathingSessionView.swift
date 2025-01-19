import SwiftUI

struct BreathingSessionView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmotionViewModel
    @StateObject private var breathingViewModel: BreathingViewModel
    @State private var scale: CGFloat = 1.0
    @State private var showControls = true
    
    init(viewModel: EmotionViewModel) {
        self.viewModel = viewModel
        self._breathingViewModel = StateObject(wrappedValue: BreathingViewModel(
            cycles: viewModel.selectedBreathingCycles,
            onComplete: {
                viewModel.saveBreathingRecord()
            }
        ))
    }
    
    // 渐变色
    private let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.1, green: 0.1, blue: 0.2),
            Color(red: 0.1, green: 0.1, blue: 0.3)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    private let breathingGradient = LinearGradient(
        colors: [
            Color(red: 0.4, green: 0.6, blue: 1.0),
            Color(red: 0.3, green: 0.4, blue: 0.9)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景层
                backgroundGradient
                    .ignoresSafeArea()
                
                // 主要内容容器
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.18))
                    .shadow(color: .black.opacity(0.3), radius: 20)
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                    .overlay {
                        // Metal粒子效果层
                        MetalParticleView(phase: breathingViewModel.currentPhase)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(.horizontal)
                            .padding(.vertical, 40)
                        
                        // 内容层
                        VStack(spacing: 0) {
                            if showControls {
                                // 顶部控制栏
                                topBar
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // 添加专注度提示文字区域
                            VStack(spacing: 8) {
                                Text(getFocusTip())
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.white.opacity(0.05))
                                    )
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 30)
                            
                            Spacer()
                            
                            // 中央呼吸区域
                            ZStack {
                                // 外圈光晕效果
                                Circle()
                                    .fill(breathingGradient)
                                    .frame(width: 220, height: 220)
                                    .blur(radius: 30)
                                    .opacity(0.3)
                                    .scaleEffect(scale)
                                
                                // 呼吸动画区域背景
                                Circle()
                                    .stroke(breathingGradient.opacity(0.3), lineWidth: 2)
                                    .frame(width: 180, height: 180)
                                
                                // 动画区域
                                Circle()
                                    .stroke(breathingGradient.opacity(0.7), lineWidth: 3)
                                    .frame(width: 180, height: 180)
                                    .scaleEffect(scale)
                                    .animation(
                                        .easeInOut(duration: breathingViewModel.currentPhase.duration)
                                        .repeatForever(autoreverses: true),
                                        value: scale
                                    )
                                
                                VStack(spacing: 16) {
                                    // 呼吸引导箭头
                                    Image(systemName: breathingViewModel.currentPhase == .inhale ? "arrow.down.circle.fill" : 
                                          breathingViewModel.currentPhase == .exhale ? "arrow.up.circle.fill" : "circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white.opacity(0.8))
                                        .opacity(breathingViewModel.currentPhase == .hold ? 0 : 1)
                                    
                                    // 状态文字
                                    VStack(spacing: 8) {
                                        Text(breathingViewModel.currentPhase.description)
                                            .font(.system(size: 36, weight: .light, design: .rounded))
                                            .foregroundColor(.white)
                                            .contentTransition(.identity)
                                        
                                        Text("保持专注")
                                            .font(.system(size: 17, weight: .regular, design: .rounded))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                            .frame(height: geometry.size.height * 0.5)
                            
                            Spacer()
                            
                            if showControls {
                                // 底部控制区
                                bottomControls
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.vertical, 40)
                    }
            }
        }
        .onChange(of: breathingViewModel.currentPhase) { oldValue, newValue in
            withAnimation(.easeInOut(duration: breathingViewModel.currentPhase == .inhale ? 4 : 4)) {
                scale = breathingViewModel.currentPhase == .inhale ? 1.5 : 1.0
            }
        }
        .onChange(of: breathingViewModel.isSessionComplete) { oldValue, newValue in
            if newValue {
                // 显示完成动画和反馈
                withAnimation(.easeInOut(duration: 0.5)) {
                    scale = 2.0
                }
                
                // 触发触觉反馈
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // 延迟后返回
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            }
        }
        .onAppear {
            startBreathingAnimation()
            breathingViewModel.startSession()
        }
        .onDisappear {
            breathingViewModel.endSession()
        }
        .statusBar(hidden: true)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                showControls.toggle()
            }
        }
    }
    
    // MARK: - Views
    private var topBar: some View {
        HStack {
            // 进度显示
            Text("第 \(breathingViewModel.currentCycle + 1)/\(viewModel.selectedBreathingCycles) 组")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.1))
                )
            
            Spacer()
            
            // 关闭按钮
            Button(action: {
                breathingViewModel.endSession()
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var breathingArea: some View {
        ZStack {
            // 外圈光晕效果
            Circle()
                .fill(breathingGradient)
                .frame(width: 220, height: 220)
                .blur(radius: 30)
                .opacity(0.3)
                .scaleEffect(scale)
            
            // 呼吸动画区域背景
            Circle()
                .stroke(breathingGradient.opacity(0.3), lineWidth: 2)
                .frame(width: 180, height: 180)
            
            // 动画区域
            Circle()
                .stroke(breathingGradient.opacity(0.7), lineWidth: 3)
                .frame(width: 180, height: 180)
                .scaleEffect(scale)
                .overlay(
                    // 添加呼吸引导箭头
                    Image(systemName: breathingViewModel.currentPhase == .inhale ? "arrow.down.circle" : 
                          breathingViewModel.currentPhase == .exhale ? "arrow.up.circle" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(breathingViewModel.currentPhase == .hold ? 0 : 1)
                )
                .animation(
                    .easeInOut(duration: breathingViewModel.currentPhase.duration)
                    .repeatForever(autoreverses: true),
                    value: scale
                )
            
            // 进度条
            GeometryReader { geo in
                let width = geo.size.width * 0.9
                
                // 进度背景
                Capsule()
                    .fill(.white.opacity(0.1))
                    .frame(width: width, height: 4)
                    .position(x: geo.size.width/2, y: geo.size.height - 20)
                
                // 进度指示器
                Capsule()
                    .fill(breathingGradient)
                    .frame(width: width * breathingViewModel.progress, height: 4)
                    .position(x: geo.size.width/2 - width/2 * (1 - breathingViewModel.progress), y: geo.size.height - 20)
            }
        }
        .blur(radius: 0.3)
    }
    
    private var bottomControls: some View {
        HStack(spacing: 40) {
            // 暂停/继续按钮
            Button(action: {
                if breathingViewModel.isActive {
                    breathingViewModel.pauseSession()
                } else {
                    breathingViewModel.resumeSession()
                }
            }) {
                Image(systemName: breathingViewModel.isActive ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.hierarchical)
            }
            
            // 结束按钮
            Button(action: {
                breathingViewModel.endSession()
                dismiss()
            }) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.8))
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Methods
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            scale = 1.5
        }
    }
    
    // 获取专注度提示
    private func getFocusTip() -> String {
        switch breathingViewModel.currentPhase {
        case .inhale:
            return "感受空气缓缓进入身体\n将注意力集中在腹部的起伏"
        case .hold:
            return "保持呼吸，感受平静\n让思绪安静下来"
        case .exhale:
            return "缓慢呼出，释放压力\n感受身体的放松"
        }
    }
}

#Preview {
    BreathingSessionView(viewModel: EmotionViewModel())
} 