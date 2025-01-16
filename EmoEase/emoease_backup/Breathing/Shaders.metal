#include <metal_stdlib>
using namespace metal;

struct Particle {
    float2 position;
    float2 velocity;
    float scale;
    float opacity;
    float4 color;
    float phase;
};

struct ParticleUniforms {
    float2 center;
    float radius;
    float deltaTime;
    float currentPhase;
};

// 顶点着色器输出/片段着色器输入结构
struct VertexOut {
    float4 position [[position]];
    float4 color;
    float opacity;
    float2 uv;
    float scale;
};

// 粒子更新计算着色器
kernel void updateParticles(device Particle *particles [[buffer(0)]],
                          constant ParticleUniforms &uniforms [[buffer(1)]],
                          uint id [[thread_position_in_grid]]) {
    Particle particle = particles[id];
    
    float2 toCenter = uniforms.center - particle.position;
    float distance = length(toCenter);
    float2 direction = distance > 0 ? toCenter / distance : float2(0);
    
    // 根据呼吸阶段调整行为
    float targetDistance = uniforms.currentPhase == 0 ? uniforms.radius * 0.3 : uniforms.radius;
    float speedFactor = min(max(distance / uniforms.radius, 0.0), 1.0);
    float movementSpeed = 0.1 * (1.0 - speedFactor);
    
    // 更新位置
    float2 targetPos = uniforms.center + direction * targetDistance;
    particle.position += (targetPos - particle.position) * movementSpeed;
    
    // 更新缩放和透明度
    float distanceFactor = distance / uniforms.radius;
    particle.scale = uniforms.currentPhase == 0 ?
        1.2 - distanceFactor * 0.7 :
        0.5 + distanceFactor * 0.7;
    
    particle.opacity = uniforms.currentPhase == 0 ?
        0.8 - distanceFactor * 0.6 :
        0.2 + distanceFactor * 0.4;
    
    // 添加一些随机扰动
    float2 noise = float2(fract(sin(distance * 12.9898 + uniforms.deltaTime) * 43758.5453),
                         fract(cos(distance * 78.233 + uniforms.deltaTime) * 43758.5453));
    particle.position += noise * 0.5;
    
    particles[id] = particle;
}

// 渲染顶点着色器
vertex VertexOut particleVertex(uint vertexID [[vertex_id]],
                              uint instanceID [[instance_id]],
                              constant Particle *particles [[buffer(0)]],
                              constant float4x4 &viewMatrix [[buffer(1)]]) {
    const float2 quadVertices[] = {
        float2(-1, -1), float2(1, -1),
        float2(-1, 1), float2(1, 1)
    };
    
    Particle particle = particles[instanceID];
    float2 position = quadVertices[vertexID];
    position *= particle.scale;
    position += particle.position;
    
    VertexOut out;
    out.position = viewMatrix * float4(position, 0, 1);
    out.color = particle.color;
    out.opacity = particle.opacity;
    out.uv = quadVertices[vertexID];
    out.scale = particle.scale;
    
    return out;
}

// 渲染片段着色器
fragment float4 particleFragment(VertexOut in [[stage_in]]) {
    float4 color = in.color;
    color.a *= in.opacity;
    
    // 添加柔和的光晕效果
    float distance = length(in.uv);
    float glow = exp(-distance * 2.0);
    color.a *= glow;
    
    // 添加基于缩放的额外效果
    float scaleEffect = smoothstep(0.3, 1.0, in.scale);
    color.rgb *= mix(0.8, 1.2, scaleEffect);
    
    return color;
} 