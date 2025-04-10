import 'package:flutter/material.dart';
import '../lib/widgets/shader_blur.dart';

/// A simple example demonstrating how to use the ShaderBlur widget
/// in a real-world application scenario.
void main() {
  runApp(const MyApp());
}

/// The main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shader Blur Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BlurExample(),
    );
  }
}

/// A simple example screen demonstrating the ShaderBlur widget
class BlurExample extends StatefulWidget {
  const BlurExample({super.key});

  @override
  State<BlurExample> createState() => _BlurExampleState();
}

class _BlurExampleState extends State<BlurExample> {
  double _blurRadius = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shader Blur Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Blur radius control
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Blur Radius: ${_blurRadius.toStringAsFixed(1)}'),
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
              ],
            ),
          ),
          
          // Example content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Example 1: Blurred Card
                    Text('Blurred Card Example', 
                      style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    BlurredCard(
                      blurRadius: _blurRadius,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: Colors.red, size: 48),
                            SizedBox(height: 8),
                            Text('Frosted Glass Card',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('This card uses ShaderBlur for a frosted glass effect'),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Example 2: Blurred Image
                    Text('Blurred Image Example', 
                      style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          children: [
                            // Original image
                            Image.network(
                              'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            
                            // Blurred overlay on half of the image
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Row(
                                children: [
                                  // Clear half
                                  const Expanded(child: SizedBox()),
                                  
                                  // Blurred half
                                  Expanded(
                                    child: ShaderBlur(
                                      blurRadius: _blurRadius,
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Text overlay
                            const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Text(
                                'Partially Blurred',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3,
                                      color: Colors.black,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom widget that creates a frosted glass card effect using ShaderBlur
class BlurredCard extends StatelessWidget {
  final Widget child;
  final double blurRadius;
  
  const BlurredCard({
    super.key,
    required this.child,
    this.blurRadius = 5.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Background with colorful gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade200,
                  Colors.purple.shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            width: 300,
            height: 150,
          ),
          
          // Blurred overlay
          ShaderBlur(
            blurRadius: blurRadius,
            child: Container(
              color: Colors.white.withOpacity(0.3),
              width: 300,
              height: 150,
            ),
          ),
          
          // Content
          SizedBox(
            width: 300,
            height: 150,
            child: child,
          ),
        ],
      ),
    );
  }
}