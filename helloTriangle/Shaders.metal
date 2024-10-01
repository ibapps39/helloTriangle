//
//  Shaders.metal
//  helloTriangle
//
//  Created by Ian Brown on 9/28/24.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_main(const device float *vertexArray [[buffer(0)]], 
                          uint vertexID [[vertex_id]]) {
    return float4(vertexArray[vertexID * 3], 
                  vertexArray[vertexID * 3 + 1],
                  vertexArray[vertexID * 3 + 2],
                  1.0);
}

fragment float4 fragment_main() {
    return float4(1.0, 0.0, 0.0, 1.0); // Red color
}
