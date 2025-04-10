import 'package:flutter/material.dart';
import 'widgets/shader_blur.dart';
import 'widgets/image_filter_blur.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double _blurRadius = 5.0;
  bool _useBlur = true;
  bool _showComparison = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create the content widget that will be blurred
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

    Widget mainContent;

    if (_showComparison) {
      // Comparison view
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
      // Single view
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // Toggle for comparison view
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
          // Toggle for blur effect (only in single view)
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
