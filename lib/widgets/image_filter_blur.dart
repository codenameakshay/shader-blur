import 'dart:ui';
import 'package:flutter/material.dart';

/// A widget that applies a blur effect to its child using Flutter's built-in ImageFilter.
class ImageFilterBlur extends StatelessWidget {
  /// The widget to apply the blur effect to.
  final Widget child;

  /// The radius of the blur effect. Higher values create a stronger blur.
  /// Default is 10.0.
  final double blurRadius;

  /// Creates an ImageFilterBlur widget.
  ///
  /// The [child] parameter is required and specifies the widget to blur.
  /// The [blurRadius] parameter specifies the strength of the blur effect.
  const ImageFilterBlur({
    super.key,
    required this.child,
    this.blurRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          // Original child (for layout purposes)
          Opacity(
            opacity: 0.0,
            child: child,
          ),

          // Blurred version
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurRadius,
              sigmaY: blurRadius,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
