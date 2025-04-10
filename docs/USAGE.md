# Using Shader Blur in Your Flutter Projects

This guide explains how to integrate the shader blur widgets into your own Flutter applications.

## Installation

First, add the required dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_shaders: ^0.1.0  # For shader support
```

Then, copy the shader files from the `shaders` directory to your project's `shaders` directory. Make sure to include them in your `pubspec.yaml`:

```yaml
flutter:
  shaders:
    - shaders/blur.frag
    - shaders/blur_android.frag
```

## Basic Usage

### ShaderBlur Widget

The `ShaderBlur` widget applies a high-quality blur effect using a fragment shader:

```dart
import 'package:your_app/widgets/shader_blur.dart';

// In your build method:
ShaderBlur(
  blurRadius: 5.0,  // Adjust blur intensity (1.0 to 10.0 recommended)
  child: YourWidget(),  // The widget to blur
)
```

### ImageFilterBlur Widget

For comparison or as a fallback, you can use the `ImageFilterBlur` widget:

```dart
import 'package:your_app/widgets/image_filter_blur.dart';

// In your build method:
ImageFilterBlur(
  blurRadius: 5.0,  // Adjust blur intensity
  child: YourWidget(),  // The widget to blur
)
```

## Advanced Usage

### Adjustable Blur

You can create a slider to adjust the blur radius dynamically:

```dart
double _blurRadius = 5.0;

// In your build method:
Column(
  children: [
    Slider(
      value: _blurRadius,
      min: 1.0,
      max: 10.0,
      divisions: 19,
      label: _blurRadius.round().toString(),
      onChanged: (double value) {
        setState(() {
          _blurRadius = value;
        });
      },
    ),
    ShaderBlur(
      blurRadius: _blurRadius,
      child: YourWidget(),
    ),
  ],
)
```

### Platform-Specific Considerations

The shader implementation automatically handles platform differences between iOS/desktop and Android. The appropriate shader file is selected based on the platform:

```dart
// From shader_blur.dart
ShaderBuilder(
  assetKey: Platform.isIOS ? 'shaders/blur.frag' : 'shaders/blur_android.frag',
  // ...
)
```

## Performance Tips

1. **Limit Blur Area**: Apply blur to smaller areas of your UI for better performance
2. **Avoid Nesting**: Don't nest multiple blur widgets
3. **Caching**: Consider caching blurred content that doesn't change frequently
4. **Adjust Radius**: Lower blur radius values require less computation

## Troubleshooting

### Common Issues

1. **Shader Compilation Errors**:
   - Make sure your shader files are correctly included in pubspec.yaml
   - Check that the shader syntax is compatible with your target platforms

2. **Performance Issues**:
   - Reduce the blur radius
   - Apply blur to smaller widgets
   - Consider using ImageFilterBlur for simpler cases

3. **Visual Artifacts**:
   - Ensure the widget is properly clipped with ClipRect
   - Check for conflicts with other visual effects

## Example

Here's a complete example of a card with blur effect:

```dart
import 'package:flutter/material.dart';
import 'package:your_app/widgets/shader_blur.dart';

class BlurredCard extends StatelessWidget {
  final Widget child;
  final double blurRadius;
  
  const BlurredCard({
    Key? key,
    required this.child,
    this.blurRadius = 5.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: ShaderBlur(
        blurRadius: blurRadius,
        child: Container(
          color: Colors.white.withOpacity(0.3),
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
```

This creates a frosted glass card effect that you can use in your UI.