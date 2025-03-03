import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// A widget that applies a Gaussian blur effect to its child using a fragment shader.
class ShaderBlur extends StatefulWidget {
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
    Key? key,
    required this.child,
    this.blurRadius = 10.0,
  }) : super(key: key);

  @override
  State<ShaderBlur> createState() => _ShaderBlurState();
}

class _ShaderBlurState extends State<ShaderBlur> with SingleTickerProviderStateMixin {
  late Future<ui.FragmentShader> _shaderFuture;
  ui.Image? _childImage;
  Size? _childSize;
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadShader();
    // Schedule a frame callback to capture the child after it's rendered
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _captureChild();
    });
  }

  @override
  void didUpdateWidget(ShaderBlur oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      // If the child changes, recapture it
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _captureChild();
      });
    }
  }

  Future<void> _loadShader() async {
    _shaderFuture = ui.FragmentProgram.fromAsset('shaders/blur.frag').then((program) => program.fragmentShader());
  }

  Future<void> _captureChild() async {
    final RenderRepaintBoundary? boundary = _childKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary != null && boundary.hasSize) {
      _childSize = boundary.size;
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      setState(() {
        // Dispose previous image if it exists
        _childImage?.dispose();
        _childImage = image;
      });
    }
  }

  @override
  void dispose() {
    _childImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hidden child that we capture
        Opacity(
          opacity: 0.0,
          child: RepaintBoundary(
            key: _childKey,
            child: widget.child,
          ),
        ),

        // Blurred version
        if (_childImage != null && _childSize != null)
          FutureBuilder<ui.FragmentShader>(
            future: _shaderFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CustomPaint(
                  size: _childSize!,
                  painter: _ShaderPainter(
                    shader: snapshot.data!,
                    image: _childImage!,
                    blurRadius: widget.blurRadius,
                  ),
                );
              } else {
                // Show a loading indicator or the original child while shader loads
                return SizedBox(
                  width: _childSize!.width,
                  height: _childSize!.height,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),

        // Fallback if no image is captured yet
        if (_childImage == null) widget.child,
      ],
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image image;
  final double blurRadius;

  _ShaderPainter({
    required this.shader,
    required this.image,
    required this.blurRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a sampler for the image
    final imageSampler = ui.ImageShader(
      image,
      ui.TileMode.clamp,
      ui.TileMode.clamp,
      Matrix4.identity().storage,
    );

    // Set shader uniforms
    shader.setFloat(0, size.width); // uResolution.x
    shader.setFloat(1, size.height); // uResolution.y
    shader.setFloat(2, blurRadius); // uBlurRadius
    shader.setImageSampler(0, image); // uTexture - pass the image directly

    // Draw the shader
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_ShaderPainter oldPainter) {
    return oldPainter.image != image || oldPainter.blurRadius != blurRadius || oldPainter.shader != shader;
  }
}
