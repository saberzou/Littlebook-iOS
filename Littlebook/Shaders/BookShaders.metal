//  BookShaders.metal
//  Littlebook
//
//  Used by SwiftUI's .colorEffect() modifier (iOS 17+).
//  Adds a physically-motivated specular highlight to the book cover
//  that moves as the book rotates, simulating a glossy surface.

#include <metal_stdlib>
using namespace metal;

/// bookSpecular — per-pixel specular highlight for a rotating book cover.
///
/// Parameters (passed from Swift via ShaderLibrary):
///   position  — pixel coordinate in the view's local space (0,0 = top-left)
///   color     — source pixel color sampled from the SwiftUI Image layer
///   size      — width × height of the cover view in points (as float2)
///   rotation  — current book rotation in radians (negative = tilted left)
[[stitchable]] half4 bookSpecular(
    float2 position,
    half4  color,
    float2 size,
    float  rotation
) {
    // Normalise position to UV space [0, 1]
    float2 uv = position / size;

    // Light source drifts horizontally as the cover rotates.
    // sin(rotation) maps [-π/2, π/2] → [-1, 1]; scale to taste.
    float lightX = 0.38 + sin(rotation) * 0.40;
    float lightY = 0.22; // fixed upper position (like a ceiling light)

    // Gaussian falloff around the light position
    float2 delta = uv - float2(lightX, lightY);
    float  dist2 = dot(delta, delta);
    float  spec  = exp(-dist2 * 11.0) * 0.28;

    // Add specular without blowing out the image colours
    return half4(
        min(1.0h, color.r + half(spec)),
        min(1.0h, color.g + half(spec)),
        min(1.0h, color.b + half(spec)),
        color.a
    );
}
