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

// Two-pass blur function (horizontal and vertical)
vec4 twoPassBlur(vec2 texCoord, float sigma) {
  // Limit the number of samples based on sigma for performance
  int samples = int(min(16.0, max(6.0, sigma * 1.5)));
  
  // First pass: Horizontal blur
  vec4 horizontalBlur = vec4(0.0);
  float horizontalWeightSum = 0.0;
  
  // Center sample
  float centerWeight = gaussian(0.0, sigma);
  horizontalBlur += texture(uTexture, texCoord) * centerWeight;
  horizontalWeightSum += centerWeight;
  
  // Calculate optimal step size based on sigma
  float stepSize = max(0.5, sigma / 3.0);
  
  // Horizontal samples
  for (int i = 1; i <= samples; i++) {
    // Apply slight jitter to reduce visible sampling pattern
    float jitter = random(texCoord + vec2(float(i) * 0.1, 0.0)) * 0.2 + 0.9;
    float offset = float(i) * stepSize * jitter;
    float weight = gaussian(offset, sigma);
    
    // Sample in both positive and negative directions
    vec2 offsetPos = vec2(offset / uResolution.x, 0.0);
    vec2 offsetNeg = vec2(-offset / uResolution.x, 0.0);
    
    horizontalBlur += texture(uTexture, texCoord + offsetPos) * weight;
    horizontalBlur += texture(uTexture, texCoord + offsetNeg) * weight;
    horizontalWeightSum += weight * 2.0;
  }
  
  // Normalize horizontal blur
  horizontalBlur /= horizontalWeightSum;
  
  // Second pass: Vertical blur on the result of horizontal blur
  vec4 finalBlur = vec4(0.0);
  float verticalWeightSum = 0.0;
  
  // Center sample (already blurred horizontally)
  finalBlur += horizontalBlur * centerWeight;
  verticalWeightSum += centerWeight;
  
  // Vertical samples
  for (int i = 1; i <= samples; i++) {
    // Apply slight jitter to reduce visible sampling pattern
    float jitter = random(texCoord + vec2(0.0, float(i) * 0.1)) * 0.2 + 0.9;
    float offset = float(i) * stepSize * jitter;
    float weight = gaussian(offset, sigma);
    
    // Sample in both positive and negative directions
    vec2 offsetPos = vec2(0.0, offset / uResolution.y);
    vec2 offsetNeg = vec2(0.0, -offset / uResolution.y);
    
    // For vertical pass, we need to sample the horizontal blur result
    // Since we can't store the intermediate texture, we need to compute it again
    
    // Compute horizontal blur for the vertical offset positions
    vec4 hBlurPos = vec4(0.0);
    vec4 hBlurNeg = vec4(0.0);
    float hWeightSumPos = 0.0;
    float hWeightSumNeg = 0.0;
    
    // Center samples for the offset positions
    hBlurPos += texture(uTexture, texCoord + offsetPos) * centerWeight;
    hBlurNeg += texture(uTexture, texCoord + offsetNeg) * centerWeight;
    hWeightSumPos += centerWeight;
    hWeightSumNeg += centerWeight;
    
    // Horizontal samples for the offset positions
    for (int j = 1; j <= samples / 2; j++) {
      float hOffset = float(j) * stepSize;
      float hWeight = gaussian(hOffset, sigma);
      
      vec2 hOffsetPos = vec2(hOffset / uResolution.x, 0.0);
      vec2 hOffsetNeg = vec2(-hOffset / uResolution.x, 0.0);
      
      hBlurPos += texture(uTexture, texCoord + offsetPos + hOffsetPos) * hWeight;
      hBlurPos += texture(uTexture, texCoord + offsetPos + hOffsetNeg) * hWeight;
      
      hBlurNeg += texture(uTexture, texCoord + offsetNeg + hOffsetPos) * hWeight;
      hBlurNeg += texture(uTexture, texCoord + offsetNeg + hOffsetNeg) * hWeight;
      
      hWeightSumPos += hWeight * 2.0;
      hWeightSumNeg += hWeight * 2.0;
    }
    
    // Normalize and add to final blur
    hBlurPos /= hWeightSumPos;
    hBlurNeg /= hWeightSumNeg;
    
    finalBlur += hBlurPos * weight;
    finalBlur += hBlurNeg * weight;
    verticalWeightSum += weight * 2.0;
  }
  
  // Normalize final blur
  return finalBlur / verticalWeightSum;
}

// Optimized radial blur for higher quality
vec4 radialBlur(vec2 texCoord, float sigma) {
  vec4 blurredColor = vec4(0.0);
  float weightSum = 0.0;
  
  // Sample center pixel
  float centerWeight = gaussian(0.0, sigma);
  blurredColor += texture(uTexture, texCoord) * centerWeight;
  weightSum += centerWeight;
  
  // Improved adaptive sampling
  int numDirections = int(min(32.0, max(16.0, 48.0 - uBlurRadius))); // 16-32 directions
  int numSteps = int(min(12.0, max(4.0, sigma * 1.2))); // 4-12 steps based on sigma
  
  // Calculate step size based on sigma for consistent blur appearance
  float stepSize = max(0.5, sigma / 4.0);
  
  // Sample in a circular pattern with jittering
  for (int step = 1; step <= numSteps; step++) {
    // Calculate distance from center for this step with slight randomization
    float distance = float(step) * stepSize;
    
    // Calculate weight based on distance from center
    float weight = gaussian(distance, sigma);
    
    // Sample in multiple directions for each step
    for (int dir = 0; dir < numDirections; dir++) {
      // Calculate angle for this direction with jitter to reduce pattern artifacts
      float angleJitter = random(texCoord + vec2(float(dir) * 0.1, float(step) * 0.1)) * 0.2;
      float angle = (float(dir) + angleJitter) * 6.28318 / float(numDirections);
      
      // Calculate offset in this direction
      vec2 offset = vec2(
        cos(angle) * distance / uResolution.x,
        sin(angle) * distance / uResolution.y
      );
      
      // Sample and accumulate
      blurredColor += texture(uTexture, texCoord + offset) * weight;
      weightSum += weight;
    }
  }
  
  // Normalize the blurred color
  return blurredColor / weightSum;
}

void main() {
  vec2 texCoord = FlutterFragCoord().xy / uResolution;
  
  // Optimized blur parameters
  float sigma = max(1.0, min(uBlurRadius / 2.0, 10.0)); // Cap sigma at 10 for performance
  
  // Choose blur method based on blur radius
  vec4 blurredColor;
  if (uBlurRadius <= 8.0) {
    // For smaller blur radii, use two-pass blur for higher quality
    blurredColor = twoPassBlur(texCoord, sigma);
  } else {
    // For larger blur radii, use optimized radial blur for better performance
    blurredColor = radialBlur(texCoord, sigma);
  }
  
  // Apply color adjustments (saturation and brightness boost)
  vec3 adjustedColor = adjustColor(blurredColor.rgb);
  
  // Add subtle noise to reduce banding (Apple-style)
  float noise = (random(texCoord) - 0.5) * 0.015;
  adjustedColor += vec3(noise);
  
  // Final color with slight transparency for the frosted glass effect
  fragColor = vec4(adjustedColor, blurredColor.a * 0.98);
}
