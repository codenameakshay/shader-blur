#version 460 core

#include <flutter/runtime_effect.glsl>

// Uniforms
uniform vec2 uResolution;
uniform float uBlurRadius;
uniform sampler2D uTexture;  // This will be our AnimatedSampler texture

out vec4 fragColor;

// Gaussian function for weight calculation
float gaussian(float x, float sigma) {
  return exp(-(x * x) / (2.0 * sigma * sigma)) / (sqrt(2.0 * 3.14159) * sigma);
}

// Pseudo-random function for noise generation
float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// HSL to RGB conversion
vec3 hsl2rgb(vec3 hsl) {
  vec3 rgb = clamp(abs(mod(hsl.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
  return hsl.z + hsl.y * (rgb - 0.5) * (1.0 - abs(2.0 * hsl.z - 1.0));
}

// RGB to HSL conversion
vec3 rgb2hsl(vec3 rgb) {
  float maxVal = max(max(rgb.r, rgb.g), rgb.b);
  float minVal = min(min(rgb.r, rgb.g), rgb.b);
  float delta = maxVal - minVal;
  
  vec3 hsl = vec3(0.0, 0.0, (maxVal + minVal) / 2.0);
  
  if (delta > 0.0) {
    hsl.y = (hsl.z < 0.5) ? (delta / (maxVal + minVal)) : (delta / (2.0 - maxVal - minVal));
    
    if (maxVal == rgb.r) {
      hsl.x = (rgb.g - rgb.b) / delta + (rgb.g < rgb.b ? 6.0 : 0.0);
    } else if (maxVal == rgb.g) {
      hsl.x = (rgb.b - rgb.r) / delta + 2.0;
    } else {
      hsl.x = (rgb.r - rgb.g) / delta + 4.0;
    }
    
    hsl.x /= 6.0;
  }
  
  return hsl;
}

void main() {
  vec2 texCoord = FlutterFragCoord().xy / uResolution;
  vec4 originalColor = texture(uTexture, texCoord);
  
  // Blur parameters
  float sigma = max(1.0, uBlurRadius / 2.0);
  int radius = int(sigma * 2.0);
  
  // Accumulate color and weights for radial blur
  vec4 blurredColor = vec4(0.0);
  float weightSum = 0.0;
  
  // Apple-style radial blur
  for (int i = -radius; i <= radius; i++) {
    for (int j = -radius; j <= radius; j++) {
      // Calculate radial distance for weight
      float distance = length(vec2(float(i), float(j)));
      
      // Skip samples that are too far (optimization)
      if (distance <= float(radius)) {
        float weight = gaussian(distance, sigma);
        vec2 offset = vec2(float(i) / uResolution.x, float(j) / uResolution.y);
        blurredColor += texture(uTexture, texCoord + offset) * weight;
        weightSum += weight;
      }
    }
  }
  
  // Normalize the blurred color
  blurredColor /= weightSum;
  
  // Convert to HSL for adjustments (Apple-style vibrancy)
  vec3 hsl = rgb2hsl(blurredColor.rgb);
  
  // Slightly increase saturation (Apple-style)
  hsl.y = min(hsl.y * 1.1, 1.0);
  
  // Slightly increase lightness for the frosted glass effect
  hsl.z = min(hsl.z * 1.05, 1.0);
  
  // Convert back to RGB
  vec3 adjustedColor = hsl2rgb(hsl);
  
  // Add subtle noise to reduce banding (Apple-style)
  float noise = (random(texCoord) - 0.5) * 0.015;
  adjustedColor += vec3(noise);
  
  // Final color with slight transparency for the frosted glass effect
  fragColor = vec4(adjustedColor, blurredColor.a * 0.98);
}
