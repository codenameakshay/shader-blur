# Shader Blur

A Flutter application demonstrating high-performance blur effects using fragment shaders, with a comparison to Flutter's built-in ImageFilter blur.

![Shader Blur Demo](https://github.com/codenameakshay/shader-blur/raw/main/screenshots/comparison_view.png)

## Overview

This project showcases the implementation of a high-quality, Apple-style blur effect in Flutter using fragment shaders. It provides a side-by-side comparison with Flutter's built-in ImageFilter blur to demonstrate the differences in visual quality and performance.

### Key Features

- **Shader-based Blur**: Custom fragment shader implementation for high-quality blur effects
- **Comparison View**: Side-by-side comparison of shader blur vs. ImageFilter blur
- **Adjustable Blur Radius**: Control the intensity of the blur effect
- **Cross-platform Support**: Works on iOS, Android, and web platforms
- **Performance Optimized**: Efficient blur implementation for smooth animations

## Screenshots

### Comparison View
![Comparison View](https://github.com/codenameakshay/shader-blur/raw/main/screenshots/comparison_view.png)

### Single View with Blur
![Single View with Blur](https://github.com/codenameakshay/shader-blur/raw/main/screenshots/single_view_blur.png)

### Single View without Blur
![Single View without Blur](https://github.com/codenameakshay/shader-blur/raw/main/screenshots/single_view_no_blur.png)

## Implementation Details

The project implements two different blur approaches:

1. **ShaderBlur**: Uses a custom GLSL fragment shader for high-quality, Apple-style blur effects
   - Located in `lib/widgets/shader_blur.dart`
   - Shader code in `shaders/blur.frag` and `shaders/blur_android.frag`
   - Features Gaussian blur with subtle enhancements for a frosted glass effect

2. **ImageFilterBlur**: Uses Flutter's built-in ImageFilter for comparison
   - Located in `lib/widgets/image_filter_blur.dart`
   - Simple implementation using Flutter's ImageFilter.blur

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version recommended)
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/codenameakshay/shader-blur.git
   ```

2. Navigate to the project directory:
   ```bash
   cd shader-blur
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

The app provides a simple interface to experiment with blur effects:

- Use the slider to adjust the blur radius
- Toggle between comparison view and single view using the compare button in the app bar
- In single view mode, use the switch to toggle blur on/off
- The floating action button increments a counter to demonstrate how the blur affects dynamic content

## How It Works

### Shader-based Blur

The shader-based blur uses a two-pass Gaussian blur algorithm implemented in GLSL. The fragment shader:

1. Samples pixels in a radius around the current pixel
2. Applies a Gaussian weight to each sample based on distance
3. Adds subtle enhancements like increased saturation and noise to reduce banding
4. Applies a slight transparency for a frosted glass effect

### Performance Considerations

The shader-based blur is generally more performant than ImageFilter blur for several reasons:

- It runs directly on the GPU
- It uses optimized sampling techniques
- It can be fine-tuned for specific visual effects

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- The Flutter Shaders package for making shader integration easier
