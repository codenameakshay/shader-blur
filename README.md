# 🌟 Shader Blur in Flutter

A sleek Flutter demo showcasing ultra-smooth, high-performance blur effects using custom fragment shaders—going beyond Flutter's built-in capabilities.

![Shader Blur Hero](https://github.com/user-attachments/assets/8f9d8060-6e4d-457b-9bd4-084d7d7010d5)

## 🚀 Overview

Elevate your UI with beautiful, GPU-powered blur effects. This app demonstrates a custom fragment shader blur compared directly with Flutter's standard `ImageFilter.blur`, highlighting significant improvements in visual quality and performance.

## ✨ Key Features

- 🎨 **Shader-Based Blur:** Advanced GPU shader implementation for stunning blur effects.
- ⚖️ **Side-by-Side Comparison:** Instantly compare shader blur vs. built-in blur.
- 🔧 **Adjustable Blur Radius:** Dynamically fine-tune blur intensity.
- 🌎 **Cross-Platform:** Seamlessly works across iOS, Android, and Web.
- ⚡ **Performance Optimized:** Achieve silky-smooth animations and transitions.

## 📸 Demo

![Shader Blur Demo GIF](https://github.com/user-attachments/assets/eaab522b-ada2-4bd9-9578-f5a54aa3d99c)

## 🛠️ Implementation Details

The project compares two blur implementations:

### 1. **ShaderBlur (Recommended)**
- **Location:** `lib/widgets/shader_blur.dart`
- **Shaders:** `shaders/blur.frag`, `shaders/blur_android.frag`
- **Highlights:** GPU-powered Gaussian blur with subtle frosted-glass enhancements.

### 2. **ImageFilterBlur (Built-in)**
- **Location:** `lib/widgets/image_filter_blur.dart`
- **Description:** Basic Flutter blur implementation for baseline comparison.

## 🚦 Getting Started

### 📋 Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Preferred IDE (VS Code, Android Studio, etc.)

### 🛠️ Installation

```bash
git clone https://github.com/codenameakshay/shader-blur.git
cd shader-blur
flutter pub get
flutter run
```

## 🎮 Using the Demo

- **Adjust Blur:** Use the slider to dynamically change blur radius.
- **Comparison Mode:** Toggle between shader and built-in blur using the app bar button.
- **Dynamic Content:** Increment a counter to see blur effects on changing UI.

## 🔬 How Shader Blur Works

Our custom blur employs a GPU-powered fragment shader:
- Applies a Gaussian distribution to sample neighboring pixels.
- Enhances visuals by subtly increasing saturation and adding noise.
- Optimizes performance with direct GPU execution.

## 📈 Performance Advantage

Shader-based blur outperforms Flutter’s built-in blur by:
- Leveraging GPU parallel processing.
- Providing smoother, visually richer blur effects.
- Reducing UI lag in animation-heavy scenarios.

## 🤝 Contributing

Feel inspired? Contributions are warmly welcomed! Simply fork and submit your PR.

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.

## 🙌 Acknowledgments

- Flutter team for an incredible framework.
- Flutter Shaders package for seamless shader integration.

