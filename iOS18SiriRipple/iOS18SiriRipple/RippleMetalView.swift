//
//  RippleMetalView.swift
//  iOS18SiriRipple
//
//  Created by be-huge on 2025/6/21.
//

import UIKit
import MetalKit

class RippleMetalView: MTKView {

    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var startTime: CFTimeInterval = 0

    required init(frame: CGRect, device: MTLDevice) {
        super.init(frame: frame, device: device);
        self.isPaused = false;
        self.enableSetNeedsDisplay = false;
        self.framebufferOnly = false;
        self.delegate = self;
        
        self.isOpaque = false;
        self.layer.isOpaque = false;
        self.clearColor = MTLClearColorMake(0, 0, 0, 0);
        self.setupMetal();
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }

    private func setupMetal() {
        guard let device = self.device else { return; }
        self.commandQueue = device.makeCommandQueue();

        let library = device.makeDefaultLibrary();
        let pipelineDesc = MTLRenderPipelineDescriptor();
        pipelineDesc.vertexFunction = library?.makeFunction(name: "vertexShader");
        pipelineDesc.fragmentFunction = library?.makeFunction(name: "fragmentShader");
        pipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm;

        do {
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDesc);
        } catch {
            fatalError("Unable to create pipeline state: \(error)");
        }

        self.startTime = CACurrentMediaTime();
    }
}

extension RippleMetalView: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard let drawable = self.currentDrawable,
              let descriptor = self.currentRenderPassDescriptor,
              let commandBuffer = self.commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        encoder.setRenderPipelineState(self.pipelineState);

        var time = Float(CACurrentMediaTime() - self.startTime);
        var resolution = SIMD2<Float>(Float(drawable.texture.width), Float(drawable.texture.height));

        encoder.setVertexBytes(&time, length: MemoryLayout<Float>.stride, index: 0);
        encoder.setVertexBytes(&resolution, length: MemoryLayout<SIMD2<Float>>.stride, index: 1);
        encoder.setFragmentBytes(&time, length: MemoryLayout<Float>.stride, index: 0);

        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4);
        encoder.endEncoding();

        commandBuffer.present(drawable);
        commandBuffer.commit();
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

