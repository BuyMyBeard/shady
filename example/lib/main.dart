import 'package:flutter/material.dart';
import 'package:shady/shady.dart';
import 'package:shady_example/shady_playground.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shady example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Material(
        child: ShadyPlayground(),
      ),
    );
  }
}
