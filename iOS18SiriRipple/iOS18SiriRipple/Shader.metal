//
//  Shader.metal
//  iOS18SiriRipple
//
//  Created by be-huge on 2025/6/21.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertexShader(
    uint vertexID [[vertex_id]],
    constant float &time [[buffer(0)]],
    constant float2 &resolution [[buffer(1)]]
) {
    VertexOut out;

    float2 positions[4] = {
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
        float2(-1.0,  1.0),
        float2( 1.0,  1.0),
    };

    float2 uv = (positions[vertexID] + 1.0) * 0.5;

    float waveX = sin((uv.y + time * 0.5) * 20.0) * 0.015;
    waveX = max(waveX, 0.0);

    float waveY = sin((uv.x + time * 0.5) * 20.0) * 0.015;
    waveY = max(waveY, 0.0);

    float2 pos = positions[vertexID];

    // 左边
    if (uv.x < 0.1) {
        pos.x -= waveX;
    }
    // 右边
    else if (uv.x > 0.9) {
        pos.x += waveX;
    }

    // 底部
    if (uv.y < 0.1) {
        pos.y -= waveY;
    }
    // 顶部
    else if (uv.y > 0.9) {
        pos.y += waveY;
    }

    out.position = float4(pos, 0.0, 1.0);
    out.uv = uv;

    return out;
}


fragment float4 fragmentShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]]) {
    float2 uv = in.uv;

    constexpr float borderBase = 0.06;

    float waveFreq = 15.0;
    float waveAmplitude = 0.015;
    float verticalScale = 0.5;

    float waveRaw = sin((uv.y + time) * waveFreq);
    float wave = waveRaw * waveAmplitude + waveAmplitude;

    float waveXRaw = sin((uv.x + time) * waveFreq + 1.57);
    float waveX = waveXRaw * waveAmplitude + waveAmplitude;

    float leftWave = borderBase + wave;
    float rightWave = borderBase + wave;
    float topWave = (borderBase + waveX) * verticalScale;
    float bottomWave = (borderBase + waveX) * verticalScale;

    bool inLeftBorder = uv.x < leftWave;
    bool inRightBorder = uv.x > (1.0 - rightWave);
    bool inBottomBorder = uv.y < bottomWave;
    bool inTopBorder = uv.y > (1.0 - topWave);

    if (!(inLeftBorder || inRightBorder || inBottomBorder || inTopBorder)) {
        return float4(0.0);
    }

    float leftAlpha = smoothstep(0.0, 1.0, (leftWave - uv.x) / leftWave);
    float rightAlpha = smoothstep(0.0, 1.0, (uv.x - (1.0 - rightWave)) / rightWave);
    float bottomAlpha = smoothstep(0.0, 1.0, (bottomWave - uv.y) / bottomWave);
    float topAlpha = smoothstep(0.0, 1.0, (uv.y - (1.0 - topWave)) / topWave);

    float edgeWeight = max(max(leftAlpha, rightAlpha), max(topAlpha, bottomAlpha));
    if (edgeWeight <= 0.0) {
        return float4(0.0);
    }

    float baseAlpha = 0.55;
    float pulse = 0.1 * sin(time * 3.0 + uv.x * 15.0 + uv.y * 15.0);

    float alpha = edgeWeight * (baseAlpha + pulse);

    float2 gradientDir1 = normalize(float2(0.8, 0.6));
    float2 gradientDir2 = normalize(float2(-0.6, 0.9));
    float t1 = dot(uv, gradientDir1) + sin(time * 2.4 + uv.x * 5.0) * 0.1;
    float t2 = dot(uv, gradientDir2) + cos(time * 1.8 + uv.y * 4.0) * 0.1;

    float3 colorA = float3(0.3, 0.8, 1.0);  // 青蓝
    float3 colorB = float3(1.0, 0.5, 0.9);  // 粉紫
    float3 colorC = float3(1.0, 0.8, 0.4);  // 橙黄
    float3 colorD = float3(0.4, 1.0, 0.6);  // 荧光绿
    float3 colorE = float3(0.8, 0.6, 1.0);  // 淡紫

    float3 mix1 = mix(colorA, colorB, smoothstep(0.0, 1.0, t1));
    float3 mix2 = mix(colorC, colorD, smoothstep(0.0, 1.0, t2));
    float3 mixedColor = mix(mix1, mix2, 0.5 + 0.5 * sin(time + t1 + t2));

    float3 blurColor = mix(mixedColor, colorE, 0.4 + 0.3 * sin(time * 1.5 + uv.x * 10.0));

    float3 finalColor = blurColor * alpha;

    return float4(finalColor, alpha);
}
