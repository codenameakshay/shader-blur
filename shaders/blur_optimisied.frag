#version 460 core

#include <flutter/runtime_effect.glsl>

// Uniforms
uniform vec2 uResolution;
uniform float uBlurRadius;
uniform sampler2D uTexture;  // This will be our AnimatedSampler texture

out vec4 fragColor;

// Optimized Gaussian function for weight calculation
float gaussian(float x, float sigma) {
  return exp(-(x * x) / (2.0 * sigma * sigma));
}

// Pseudo-random function for noise generation
float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Optimized color adjustment function that preserves Apple-style vibrancy
vec3 adjustColor(vec3 color) {
  // Calculate luminance
  float luminance = dot(color, vec3(0.299, 0.587, 0.114));
  vec3 gray = vec3(luminance);
  
  // Boost saturation (Apple-style vibrancy)
  vec3 saturated = mix(gray, color, 1.1); // 10% saturation boost
  
  // Slightly increase brightness for the frosted glass effect
  vec3 brightened = saturated * 1.05; // 5% brightness boost
  
  // Subtle contrast enhancement
  return mix(vec3(0.5), brightened, 1.05);
}

void main() {
  vec2 texCoord = FlutterFragCoord().xy / uResolution;
  
  // Optimized blur parameters
  float sigma = max(1.0, min(uBlurRadius / 2.0, 10.0)); // Cap sigma at 10 for performance
  
  // Accumulate color and weights for blur
  vec4 blurredColor = vec4(0.0);
  float weightSum = 0.0;
  
  // Sample center pixel
  float centerWeight = gaussian(0.0, sigma);
  blurredColor += texture(uTexture, texCoord) * centerWeight;
  weightSum += centerWeight;
  
  // Enhanced adaptive sampling with golden ratio spiral pattern
  // This creates a more natural-looking blur with fewer visible artifacts
  int numSamples = int(min(64.0, max(32.0, 96.0 - uBlurRadius * 2.0))); // Adaptive sample count
  
  // Golden angle in radians (approximately 2.4 radians or 137.5 degrees)
  // This creates a spiral pattern that distributes samples more evenly
  const float goldenAngle = 2.39996323;
  
  // Calculate optimal step size based on sigma for consistent blur appearance
  float maxRadius = sigma * 3.0; // Cover 3 sigma for good quality
  
  for (int i = 1; i <= numSamples; i++) {
    // Calculate radius using square root to distribute samples more evenly across the disk
    float radius = sqrt(float(i) / float(numSamples)) * maxRadius;
    
    // Calculate angle using golden angle to create a spiral pattern
    float angle = float(i) * goldenAngle;
    
    // Add slight jitter to reduce visible patterns
    float radiusJitter = random(texCoord + vec2(cos(angle), sin(angle))) * 0.1 + 0.95;
    radius *= radiusJitter;
    
    // Calculate weight based on distance from center
    float weight = gaussian(radius, sigma);
    
    // Calculate offset in this direction
    vec2 offset = vec2(
      cos(angle) * radius / uResolution.x,
      sin(angle) * radius / uResolution.y
    );
    
    // Sample and accumulate
    blurredColor += texture(uTexture, texCoord + offset) * weight;
    weightSum += weight;
  }
  
  // Normalize the blurred color
  blurredColor /= weightSum;
  
  // Apply color adjustments (saturation and brightness boost)
  vec3 adjustedColor = adjustColor(blurredColor.rgb);
  
  // Add subtle noise to reduce banding (Apple-style)
  float noise = (random(texCoord) - 0.5) * 0.015;
  adjustedColor += vec3(noise);
  
  // Final color with slight transparency for the frosted glass effect
  fragColor = vec4(adjustedColor, blurredColor.a * 0.98);
}
