//
//  MetalView.swift
//  helloTriangle
//
//  Created by Ian Brown on 9/28/24.
//

import SwiftUI
import Metal
import MetalKit
// If you need to use types like float2, float3, float4, and etc.. var x: [float4]
//import simd

/*/
 
 Getting started with Metal in Swift and SwiftUI is exciting! Here's a simplified breakdown of the core components you need to set up for a basic Metal application:
 
 Device: This represents the GPU and is your entry point to Metal. You create a MTLDevice.
 Command Queue: This manages the submission of commands to the GPU. You create a MTLCommandQueue.
 Vertex Buffer: This holds the vertex data for your shapes. You create a MTLBuffer to store your vertices.
 Render Pipeline State: This defines how your graphics will be rendered, including the vertex and fragment shaders.
 Command Buffer: This is a container for the commands you want to send to the GPU.
 Drawable: In the context of Metal and a Metal view, you need a drawable for rendering to the screen, typically handled with MTKView.
 Render Pass Descriptor: This describes the attachments (like color attachments) for rendering.
 */

struct MetalView: UIViewRepresentable {
    let device: MTLDevice
    var commandQueue: MTLCommandQueue
    var vertexBuffer: MTLBuffer
    var library: MTLLibrary
    var pipelineState: MTLRenderPipelineState
    var pixelFormat: MTLPixelFormat
    
    // Told "typically" vertices are now in Swift plain in text or even Metal file.
    let vertexDataSwift: [Float] =
    [0,  1, 0,
     -1, -1, 0,
     1, -1, 0]
    
    init() {
        guard let device: MTLDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Error: device")
        }
        self.device = device
        
        guard let commandQueue: MTLCommandQueue = device.makeCommandQueue() else {
            fatalError("Error: cmdQ")
        }
        self.commandQueue = commandQueue
        
        // In case no Swift File
        vertexBuffer = device.makeBuffer(bytes: vertexDataSwift,
                                         length: vertexDataSwift.count * MemoryLayout<Float>.size,
                                         options: [])!
        
        // Setup Pipeline State
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Error: Library")
        }
        self.library = library
        let vertexFunction = library.makeFunction(name:"vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")
        
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = vertexFunction
        pipelineDesc.fragmentFunction = fragmentFunction
        
        let pixelFormat: MTLPixelFormat = .bgra8Unorm
        self.pixelFormat = pixelFormat
        
        pipelineDesc.colorAttachments[0].pixelFormat = pixelFormat
        
        do {
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDesc)
        } catch {
            fatalError("Unable to create pipeline state: \(error)")
        }
    }
    
    func makeUIView(context: Context) -> MTKView {
        print("Creating MTKView")
        let mtkView = MTKView(frame: .zero, device: device)
        mtkView.colorPixelFormat = pixelFormat
        mtkView.backgroundColor = UIColor.black
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.delegate = context.coordinator
        // Optional: Set the view's preferred frames per second
        mtkView.preferredFramesPerSecond = 60
        
        return mtkView
    }
    
    func updateUIView(_ uiView:MTKView, context: Context) {
        // redraw
        print("Updating MTKView")
        draw(in: uiView)
    }
    private func draw(in view: MTKView) {
        // Get anything thats ready to render or exit
        guard let drawable = view.currentDrawable else {
            print("!!!NO DRAWABLE")
            return
        }
        guard let descriptor = view.currentRenderPassDescriptor else {
            print("!!!NO RENDER PASS DESC AVAILABLE")
            return
        }
        
        // From q, make a buffer and from the buffer make an encoder to further process instructions
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        
        // Encoder work
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
// Used some gpt for this, lol it stole from HWS hard for the Coordinator code
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView
        init(_ parent: MetalView) {
            self.parent = parent
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            //
        }
        func draw(in view: MTKView) {
            parent.draw(in: view)
        }
        deinit {
                // Handle cleanup here
                print("Coordinator==>MetalView is being deinitialized, releasing resources.")
            }
    }
    
}

