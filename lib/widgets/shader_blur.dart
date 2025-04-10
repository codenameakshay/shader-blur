import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

/// A widget that applies a blur effect to its child using a fragment shader.
class ShaderBlur extends StatelessWidget {
  /// The widget to apply the blur effect to.
  final Widget child;

  /// The radius of the blur effect. Higher values create a stronger blur.
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
    return ClipRect(
      child: ShaderBuilder(
        assetKey: Platform.isIOS ? 'shaders/blur.frag' : 'shaders/blur_android.frag',
        (BuildContext context, ui.FragmentShader shader, Widget? child) {
          return AnimatedSampler(
            (ui.Image image, Size size, Canvas canvas) {
              // Set shader uniforms
              shader.setFloat(0, size.width); // uResolution.x
              shader.setFloat(1, size.height); // uResolution.y
              shader.setFloat(2, blurRadius); // uBlurRadius
              shader.setImageSampler(0, image); // uTexture

              // Draw with shader
              canvas.drawRect(
                Rect.fromLTWH(0, 0, size.width, size.height),
                Paint()..shader = shader,
              );
            },
            child: this.child,
          );
        },
        child: child, // Pass child to ShaderBuilder
      ),
    );
  }
}
