import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

/// A high-performance widget that applies an Apple-style blur effect to its child
/// using a custom fragment shader.
///
/// This implementation uses GPU-accelerated shaders for better performance compared
/// to Flutter's built-in ImageFilter blur. The shader implements a Gaussian blur
/// with additional enhancements for a more aesthetically pleasing result.
///
/// Features:
/// - High-quality Gaussian blur algorithm
/// - Subtle saturation and lightness adjustments for a frosted glass effect
/// - Noise addition to reduce banding artifacts
/// - Platform-specific shader selection for iOS/desktop and Android
///
/// Performance considerations:
/// - More efficient than ImageFilter for medium to large blur radii
/// - Best used on smaller UI elements rather than full-screen blurs
/// - Automatically clips content to prevent shader sampling outside bounds
class ShaderBlur extends StatelessWidget {
  /// The widget to apply the blur effect to.
  /// This widget will be rendered to a texture and then blurred.
  final Widget child;

  /// The radius of the blur effect. Higher values create a stronger blur.
  /// 
  /// Recommended values:
  /// - 1.0-3.0: Subtle blur (best for text backgrounds)
  /// - 4.0-7.0: Medium blur (good for card effects)
  /// - 8.0-15.0: Strong blur (for dramatic effects)
  /// 
  /// Values above 20.0 may impact performance on lower-end devices.
  /// Default is 10.0.
  final double blurRadius;

  /// Creates a ShaderBlur widget.
  ///
  /// The [child] parameter is required and specifies the widget to blur.
  /// The [blurRadius] parameter specifies the strength of the blur effect.
  const ShaderBlur({
    super.key,
    required this.child,
    this.blurRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    // ClipRect is important to prevent the shader from sampling outside the bounds
    return ClipRect(
      child: ShaderBuilder(
        // Select the appropriate shader based on platform
        // iOS/desktop and Android have slightly different shader implementations
        // due to differences in GLSL support and performance characteristics
        assetKey: Platform.isIOS ? 'shaders/blur.frag' : 'shaders/blur_android.frag',
        (BuildContext context, ui.FragmentShader shader, Widget? child) {
          // AnimatedSampler captures the child widget as a texture
          // and provides it to the shader for processing
          return AnimatedSampler(
            (ui.Image image, Size size, Canvas canvas) {
              // Set shader uniforms
              shader.setFloat(0, size.width);  // uResolution.x - width of the texture
              shader.setFloat(1, size.height); // uResolution.y - height of the texture
              shader.setFloat(2, blurRadius);  // uBlurRadius - strength of the blur effect
              shader.setImageSampler(0, image); // uTexture - the captured image of the child widget
              
              // Draw a rectangle covering the entire area with the shader applied
              canvas.drawRect(
                Rect.fromLTWH(0, 0, size.width, size.height),
                Paint()..shader = shader,
              );
            },
            child: this.child, // The widget to be blurred
          );
        },
        child: child, // Pass child to ShaderBuilder for initial layout
      ),
    );
  }
}
