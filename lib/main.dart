import 'package:flutter/material.dart';
import 'widgets/shader_blur.dart';
import 'widgets/image_filter_blur.dart';

/// ShaderBlur Demo Application
/// 
/// This application demonstrates the use of fragment shaders for creating
/// high-quality blur effects in Flutter, comparing them with Flutter's built-in
/// ImageFilter blur. The app showcases performance differences and visual quality
/// between the two approaches.
void main() {
  runApp(const MyApp());
}

/// The main application widget.
/// 
/// This is the root widget of the application that sets up the MaterialApp
/// with the appropriate theme and home page.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Shader Blur Demo'),
    );
  }
}

/// The main page of the application.
///
/// This stateful widget serves as the primary interface for the blur demonstration.
/// It allows users to:
/// - Toggle between single view and comparison view
/// - Adjust blur radius using a slider
/// - Toggle blur effect on/off in single view
/// - Compare shader-based blur with ImageFilter blur side by side
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  /// The title displayed in the app bar
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// The state for the MyHomePage widget.
///
/// This class manages the state and UI for the blur demonstration.
class _MyHomePageState extends State<MyHomePage> {
  /// Counter for the demo content
  int _counter = 0;
  
  /// Current blur radius value (1.0 to 10.0)
  double _blurRadius = 5.0;
  
  /// Whether blur effect is enabled in single view mode
  bool _useBlur = true;
  
  /// Whether comparison view is active (showing both blur implementations side by side)
  bool _showComparison = false;

  /// Increments the counter when the floating action button is pressed
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Creates the demo content that will be blurred
    /// 
    /// This includes text, colored containers, an image, and a progress indicator
    /// to demonstrate how different UI elements appear when blurred.
    Widget buildContent() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
              textAlign: TextAlign.center,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            // Add some colorful elements to better demonstrate the blur
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  color: Colors.red,
                ),
                Container(
                  width: 40,
                  height: 40,
                  color: Colors.green,
                ),
                Container(
                  width: 40,
                  height: 40,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Image.network(
              'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              color: Colors.red,
            ),
          ],
        ),
      );
    }

    // Determine which view to show: comparison or single view
    Widget mainContent;

    if (_showComparison) {
      // Comparison view - shows shader blur and ImageFilter blur side by side
      mainContent = Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Blur Radius: ${_blurRadius.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
          Expanded(
            child: Row(
              children: [
                // Left side: Shader Blur
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Shader Blur',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ShaderBlur(
                            blurRadius: _blurRadius,
                            child: buildContent(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side: ImageFilter Blur
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ImageFilter Blur',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ImageFilterBlur(
                            blurRadius: _blurRadius,
                            child: buildContent(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Single view - shows only one blur implementation (shader blur) or no blur
      Widget content = buildContent();

      // Apply blur if enabled
      if (_useBlur) {
        content = ShaderBlur(
          blurRadius: _blurRadius,
          child: content,
        );
      }

      mainContent = Column(
        children: [
          if (_useBlur)
            Padding(
              padding: const EdgeInsets.all(8.0),
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
          Expanded(child: content),
        ],
      );
    }

    // Build the main scaffold with app bar and controls
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // Toggle button for comparison view (side-by-side blur implementations)
          IconButton(
            icon: Icon(_showComparison ? Icons.compare : Icons.compare_arrows),
            tooltip: 'Toggle Comparison View',
            onPressed: () {
              setState(() {
                _showComparison = !_showComparison;
                // Always enable blur in comparison mode
                if (_showComparison) {
                  _useBlur = true;
                }
              });
            },
          ),
          // Toggle switch for enabling/disabling blur effect (only available in single view mode)
          if (!_showComparison)
            Switch(
              value: _useBlur,
              onChanged: (value) {
                setState(() {
                  _useBlur = value;
                });
              },
            ),
        ],
      ),
      body: mainContent,
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
