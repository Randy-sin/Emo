import Metal
import MetalKit
import SwiftUI

final class MetalRenderer: ObservableObject {
    @Published var isValid: Bool = false
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let library: MTLLibrary
    private let computePipelineState: MTLComputePipelineState
    private let renderPipelineState: MTLRenderPipelineState
    private let particleBuffer: MTLBuffer
    private let uniformBuffer: MTLBuffer
    
    // 常量
    private let particleCount = 150
    private let maxBufferSize = 16384 // 16KB for uniforms
    
    init?() {
        // 初始化Metal设备
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        self.device = device
        
        // 创建命令队列
        guard let queue = device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
        
        // 加载Metal库
        guard let library = device.makeDefaultLibrary() else { return nil }
        self.library = library
        
        // 创建计算管线
        guard let computeFunction = library.makeFunction(name: "updateParticles"),
              let computePipelineState = try? device.makeComputePipelineState(function: computeFunction) else {
            return nil
        }
        self.computePipelineState = computePipelineState
        
        // 创建渲染管线
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        guard let vertexFunction = library.makeFunction(name: "particleVertex"),
              let fragmentFunction = library.makeFunction(name: "particleFragment") else {
            return nil
        }
        
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            return nil
        }
        self.renderPipelineState = renderPipelineState
        
        // 创建粒子缓冲区
        guard let particleBuffer = device.makeBuffer(length: MemoryLayout<Particle>.stride * particleCount,
                                                   options: .storageModeShared) else {
            return nil
        }
        self.particleBuffer = particleBuffer
        
        // 创建uniform缓冲区
        guard let uniformBuffer = device.makeBuffer(length: maxBufferSize,
                                                  options: .storageModeShared) else {
            return nil
        }
        self.uniformBuffer = uniformBuffer
        
        // 初始化粒子
        initializeParticles()
        isValid = true
    }
    
    private func initializeParticles() {
        let particles = particleBuffer.contents().assumingMemoryBound(to: Particle.self)
        
        for i in 0..<particleCount {
            let angle = Double.random(in: 0..<2 * .pi)
            let distance = Double.random(in: 0..<180)
            let position = SIMD2<Float>(
                Float(cos(angle) * distance),
                Float(sin(angle) * distance)
            )
            
            let baseHue = Float.random(in: 0.55...0.65)
            let saturation = Float.random(in: 0.6...0.8)
            let brightness = Float.random(in: 0.8...1.0)
            
            particles[i] = Particle(
                position: position,
                velocity: SIMD2<Float>(0, 0),
                scale: Float.random(in: 0.3...1.0),
                opacity: Float.random(in: 0.2...0.6),
                color: SIMD4<Float>(baseHue, saturation, brightness, 1.0),
                phase: 0
            )
        }
    }
    
    func update(phase: BreathingPhase, center: CGPoint, size: CGSize, deltaTime: Float) {
        guard isValid,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        
        var uniforms = ParticleUniforms(
            center: SIMD2<Float>(Float(center.x), Float(center.y)),
            radius: 180,
            deltaTime: deltaTime,
            currentPhase: Float(phase == .inhale ? 0 : 1)
        )
        
        withUnsafePointer(to: &uniforms) { ptr in
            uniformBuffer.contents().copyMemory(from: ptr, byteCount: MemoryLayout<ParticleUniforms>.size)
        }
        
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(uniformBuffer, offset: 0, index: 1)
        
        // 使用固定大小的线程组
        let threadgroupSize = MTLSize(width: 32, height: 1, depth: 1)  // 使用固定的线程组大小
        let threadgroups = MTLSize(
            width: (particleCount + threadgroupSize.width - 1) / threadgroupSize.width,
            height: 1,
            depth: 1
        )
        
        computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
    }
    
    func render(in view: MTKView) {
        guard isValid,
              let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)
        
        var viewMatrix = matrix_identity_float4x4
        renderEncoder.setVertexBytes(&viewMatrix, length: MemoryLayout<float4x4>.size, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangleStrip,
                                   vertexStart: 0,
                                   vertexCount: 4,
                                   instanceCount: particleCount)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - Metal数据结构
extension MetalRenderer {
    struct Particle {
        var position: SIMD2<Float>
        var velocity: SIMD2<Float>
        var scale: Float
        var opacity: Float
        var color: SIMD4<Float>
        var phase: Float
    }
    
    struct ParticleUniforms {
        var center: SIMD2<Float>
        var radius: Float
        var deltaTime: Float
        var currentPhase: Float
    }
} 