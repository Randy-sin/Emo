import SwiftUI
import MetalKit

struct MetalParticleView: UIViewRepresentable {
    let phase: BreathingPhase
    @StateObject private var renderer = MetalRenderer() ?? MetalRenderer()!
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        metalView.delegate = context.coordinator
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        metalView.isOpaque = false
        metalView.enableSetNeedsDisplay = true
        metalView.framebufferOnly = false
        
        context.coordinator.metalView = metalView
        context.coordinator.setupDisplayLink()
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.phase = phase
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalParticleView
        var phase: BreathingPhase
        private var displayLink: CADisplayLink?
        private var lastUpdateTime: CFTimeInterval = 0
        weak var metalView: MTKView?
        
        init(_ parent: MetalParticleView) {
            self.parent = parent
            self.phase = parent.phase
            super.init()
        }
        
        deinit {
            displayLink?.invalidate()
        }
        
        func setupDisplayLink() {
            displayLink?.invalidate()
            displayLink = CADisplayLink(target: self, selector: #selector(update))
            displayLink?.preferredFramesPerSecond = 60
            displayLink?.add(to: .main, forMode: .common)
        }
        
        @objc func update() {
            guard parent.renderer.isValid,
                  let view = metalView else { return }
            
            let currentTime = CACurrentMediaTime()
            let deltaTime = Float(lastUpdateTime > 0 ? currentTime - lastUpdateTime : 1.0 / 60.0)
            lastUpdateTime = currentTime
            
            let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            
            parent.renderer.update(
                phase: phase,
                center: center,
                size: view.bounds.size,
                deltaTime: deltaTime
            )
            
            view.setNeedsDisplay()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // 处理视图大小变化
        }
        
        func draw(in view: MTKView) {
            if parent.renderer.isValid {
                parent.renderer.render(in: view)
            }
        }
    }
}

#Preview {
    MetalParticleView(phase: .inhale)
        .frame(width: 300, height: 300)
        .background(Color.black.opacity(0.1))
} 