#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uBlurRadius;
uniform sampler2D uTexture;

out vec4 fragColor;

// Gaussian function for weight calculation
float gaussian(float x, float sigma) {
  return exp(-(x * x) / (2.0 * sigma * sigma)) / (sqrt(2.0 * 3.14159) * sigma);
}

void main() {
  vec2 texCoord = FlutterFragCoord().xy / uResolution;
  
  // Calculate pixel size for sampling
  vec2 pixelSize = 1.0 / uResolution;
  
  // Blur parameters
  float sigma = uBlurRadius / 3.0; // Standard deviation
  int kernelSize = int(uBlurRadius * 2.0 + 1.0); // Kernel size based on radius
  
  // Ensure kernel size is odd
  kernelSize = kernelSize + (1 - kernelSize % 2);
  
  // Center of the kernel
  int kernelCenter = kernelSize / 2;
  
  // Accumulate color and weights
  vec4 colorSum = vec4(0.0);
  float weightSum = 0.0;
  
  // Two-pass Gaussian blur (horizontal pass)
  for (int i = 0; i < kernelSize; i++) {
    int offset = i - kernelCenter;
    float weight = gaussian(float(offset), sigma);
    vec2 sampleCoord = texCoord + vec2(offset * pixelSize.x, 0.0);
    colorSum += texture(uTexture, sampleCoord) * weight;
    weightSum += weight;
  }
  
  // Normalize the result
  vec4 horizontalBlur = colorSum / weightSum;
  
  // Reset accumulators for vertical pass
  colorSum = vec4(0.0);
  weightSum = 0.0;
  
  // Vertical pass
  for (int i = 0; i < kernelSize; i++) {
    int offset = i - kernelCenter;
    float weight = gaussian(float(offset), sigma);
    vec2 sampleCoord = texCoord + vec2(0.0, offset * pixelSize.y);
    colorSum += texture(uTexture, sampleCoord) * weight;
    weightSum += weight;
  }
  
  // Normalize the result
  vec4 verticalBlur = colorSum / weightSum;
  
  // Combine horizontal and vertical blur
  fragColor = (horizontalBlur + verticalBlur) * 0.5;
}
