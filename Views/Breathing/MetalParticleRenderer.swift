import Metal
import MetalKit
import SwiftUI

class MetalParticleRenderer: NSObject {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let library: MTLLibrary
    
    // 计算管线
    private let computePipelineState: MTLComputePipelineState
    
    // 渲染管线
    private let renderPipelineState: MTLRenderPipelineState
    
    // 粒子缓冲区
    private let particleBuffer: MTLBuffer
    private let uniformBuffer: MTLBuffer
    
    // 常量
    private let particleCount = 150
    private let maxBufferSize = 16384 // 16KB for uniforms
    
    // 状态标记
    private(set) var isValid: Bool = false
    
    // 错误处理
    enum RendererError: Error {
        case deviceNotFound
        case libraryNotFound
        case functionNotFound
        case pipelineCreationFailed
    }
    
    override init() {
        // 初始化Metal设备
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal设备不可用")
        }
        self.device = device
        
        // 创建命令队列
        guard let queue = device.makeCommandQueue() else {
            fatalError("无法创建命令队列")
        }
        self.commandQueue = queue
        
        // 加载Metal库
        guard let library = device.makeDefaultLibrary() else {
            fatalError("无法加载Metal库")
        }
        self.library = library
        
        // 创建计算管线
        guard let computeFunction = library.makeFunction(name: "updateParticles"),
              let computePipelineState = try? device.makeComputePipelineState(function: computeFunction) else {
            fatalError("无法创建计算管线")
        }
        self.computePipelineState = computePipelineState
        
        // 创建渲染管线
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        guard let vertexFunction = library.makeFunction(name: "particleVertex"),
              let fragmentFunction = library.makeFunction(name: "particleFragment") else {
            fatalError("无法创建着色器函数")
        }
        
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("无法创建渲染管线")
        }
        self.renderPipelineState = renderPipelineState
        
        // 创建粒子缓冲区
        guard let particleBuffer = device.makeBuffer(length: MemoryLayout<Particle>.stride * particleCount,
                                                   options: .storageModeShared) else {
            fatalError("无法创建粒子缓冲区")
        }
        self.particleBuffer = particleBuffer
        
        // 创建uniform缓冲区
        guard let uniformBuffer = device.makeBuffer(length: maxBufferSize,
                                                  options: .storageModeShared) else {
            fatalError("无法创建Uniform缓冲区")
        }
        self.uniformBuffer = uniformBuffer
        
        super.init()
        
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
        
        // 设置计算编码器
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(uniformBuffer, offset: 0, index: 1)
        
        let threadsPerGrid = MTLSize(width: particleCount, height: 1, depth: 1)
        let threadsPerThreadgroup = MTLSize(width: min(particleCount, 256), height: 1, depth: 1)
        
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
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
        
        // 设置渲染编码器
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)
        
        // 设置视图矩阵
        var viewMatrix = matrix_identity_float4x4
        renderEncoder.setVertexBytes(&viewMatrix, length: MemoryLayout<float4x4>.size, index: 1)
        
        // 绘制粒子
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
extension MetalParticleRenderer {
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