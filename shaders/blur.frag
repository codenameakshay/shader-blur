#version 460 core

#include <flutter/runtime_effect.glsl>

//------------------------------------------------------------------------------
// Shader Blur Fragment Shader (iOS/Desktop version)
//
// This shader implements a high-quality Gaussian blur with Apple-style
// enhancements for a frosted glass effect. It includes subtle saturation
// adjustments and noise to reduce banding.
//------------------------------------------------------------------------------

// Uniforms
uniform vec2 uResolution;    // The size of the texture in pixels
uniform float uBlurRadius;   // The radius of the blur effect (1.0 to 10.0)
uniform sampler2D uTexture;  // The input texture to be blurred

// Output color
out vec4 fragColor;

// Gaussian function for weight calculation
// This implements the standard Gaussian distribution formula
// for determining the weight of each sample based on distance
float gaussian(float x, float sigma) {
  return exp(-(x * x) / (2.0 * sigma * sigma)) / (sqrt(2.0 * 3.14159) * sigma);
}

// Pseudo-random function for noise generation
// Used to add subtle noise to reduce banding artifacts in the blur
float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// HSL to RGB conversion
// Converts a color from HSL (Hue, Saturation, Lightness) to RGB color space
// Used for color adjustments in the blur effect
vec3 hsl2rgb(vec3 hsl) {
  vec3 rgb = clamp(abs(mod(hsl.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
  return hsl.z + hsl.y * (rgb - 0.5) * (1.0 - abs(2.0 * hsl.z - 1.0));
}

// RGB to HSL conversion
// Converts a color from RGB to HSL (Hue, Saturation, Lightness) color space
// Used for color adjustments in the blur effect
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

// Main shader function
void main() {
  // Convert fragment coordinates to texture coordinates
  vec2 texCoord = FlutterFragCoord().xy / uResolution;
  
  // Get the original color at this pixel
  vec4 originalColor = texture(uTexture, texCoord);
  
  // Calculate blur parameters based on the blur radius
  // Sigma is the standard deviation for the Gaussian function
  float sigma = max(1.0, uBlurRadius / 2.0);
  
  // Determine the sampling radius based on sigma
  // We sample pixels within 2*sigma distance for a good approximation
  int radius = int(sigma * 2.0);
  
  // Initialize accumulators for the blur calculation
  vec4 blurredColor = vec4(0.0);  // Accumulated color
  float weightSum = 0.0;          // Sum of weights for normalization
  
  // Perform a radial Gaussian blur by sampling in both x and y directions
  for (int i = -radius; i <= radius; i++) {
    for (int j = -radius; j <= radius; j++) {
      // Calculate the distance from the center for this sample
      float distance = length(vec2(float(i), float(j)));
      
      // Skip samples that are too far away (optimization)
      if (distance <= float(radius)) {
        // Calculate the Gaussian weight for this sample
        float weight = gaussian(distance, sigma);
        
        // Calculate the offset in texture coordinates
        vec2 offset = vec2(float(i) / uResolution.x, float(j) / uResolution.y);
        
        // Sample the texture at the offset position and apply weight
        blurredColor += texture(uTexture, texCoord + offset) * weight;
        
        // Accumulate the weight
        weightSum += weight;
      }
    }
  }
  
  // Normalize the blurred color by dividing by the sum of weights
  blurredColor /= weightSum;
  
  //----------------------------------------------------------------------
  // Apple-style enhancements for a more aesthetically pleasing blur
  //----------------------------------------------------------------------
  
  // Convert to HSL for color adjustments
  vec3 hsl = rgb2hsl(blurredColor.rgb);
  
  // Slightly increase saturation for a more vibrant look
  hsl.y = min(hsl.y * 1.1, 1.0);
  
  // Slightly increase lightness for the frosted glass effect
  hsl.z = min(hsl.z * 1.05, 1.0);
  
  // Convert back to RGB after adjustments
  vec3 adjustedColor = hsl2rgb(hsl);
  
  // Add subtle noise to reduce banding artifacts
  float noise = (random(texCoord) - 0.5) * 0.015;
  adjustedColor += vec3(noise);
  
  // Final color with slight transparency for the frosted glass effect
  fragColor = vec4(adjustedColor, blurredColor.a * 0.98);
}
