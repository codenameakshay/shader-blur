import 'dart:ui';
import 'package:flutter/material.dart';

/// A widget that applies a blur effect to its child using Flutter's built-in ImageFilter.
///
/// This implementation uses Flutter's standard ImageFilter.blur for comparison with
/// the custom shader-based blur. It provides a simpler implementation but may be less
/// performant for larger blur radii or complex scenes.
///
/// Features:
/// - Uses Flutter's built-in blur implementation
/// - Simple API with minimal configuration
/// - Consistent appearance across all platforms
///
/// Performance considerations:
/// - Less efficient than shader-based blur for medium to large blur radii
/// - May cause jank on complex UIs with large blur areas
/// - Uses a stack with an invisible copy of the child for proper layout sizing
class ImageFilterBlur extends StatelessWidget {
  /// The widget to apply the blur effect to.
  /// This widget will be rendered with Flutter's built-in blur filter.
  final Widget child;

  /// The radius of the blur effect. Higher values create a stronger blur.
  /// 
  /// This value is passed directly to ImageFilter.blur as sigma values.
  /// Note that ImageFilter blur behaves differently than shader blur at
  /// the same radius values - typically ImageFilter blur appears stronger.
  /// 
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
    // ClipRect prevents the blur from extending outside the widget's bounds
    return ClipRect(
      child: Stack(
        children: [
          // Original child with zero opacity (for layout purposes only)
          // This ensures the stack takes the correct size of the child
          // without this, the blur might not size correctly
          Opacity(
            opacity: 0.0,
            child: child,
          ),

          // Blurred version of the child
          // ImageFiltered applies the blur effect using Flutter's built-in ImageFilter
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurRadius, // Horizontal blur amount
              sigmaY: blurRadius, // Vertical blur amount (same as horizontal for uniform blur)
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
