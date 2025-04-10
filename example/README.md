# Shader Blur Examples

This directory contains example implementations demonstrating how to use the Shader Blur widgets in various scenarios.

## Simple Example

The `simple_example.dart` file demonstrates:

1. How to use the `ShaderBlur` widget in a real application
2. Creating a frosted glass card effect
3. Applying partial blur to an image
4. Dynamically adjusting the blur radius

### Running the Example

To run the simple example:

```bash
cd shader-blur
flutter run -t example/simple_example.dart
```

## Usage Notes

The examples show best practices for implementing blur effects:

- Always wrap blur widgets with `ClipRect` or `ClipRRect` to prevent overflow
- Use stacks to layer content over blurred backgrounds
- Apply blur to the smallest necessary area for best performance
- Consider the visual hierarchy when applying blur effects

## Custom Implementations

The `BlurredCard` widget in the example shows how to create a reusable component that incorporates the shader blur effect. This pattern can be extended to create various UI elements like:

- Frosted glass navigation bars
- Blurred modal overlays
- Depth-of-field effects for images
- Dynamic background blurring

## Screenshots

When running the examples, you should see results similar to these:

- Blurred Card: A card with a frosted glass effect and gradient background
- Partially Blurred Image: An image with the right half blurred to demonstrate selective blurring

Feel free to modify these examples to experiment with different blur configurations and use cases.