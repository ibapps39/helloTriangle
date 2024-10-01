//
//  VertexIn.swift
//  helloTriangle
//
//  Created by Ian Brown on 9/30/24.
//


#include <metal_stdlib>
using namespace metal;

// Vertex data structure
struct VertexIn {
    float4 position [[attribute(0)]];
};

// Fragment output
fragment float4 fragment_main() {
    return float4(1.0, 0.0, 0.0, 1.0); // Red color
}

// Vertex function
vertex float4 vertex_main(VertexIn in [[stage_in]]) {
    return in.position; // Pass through vertex position
}
