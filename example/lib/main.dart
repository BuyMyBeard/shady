import 'package:flutter/material.dart';
import 'package:shady_example/gallery/shady_gallery.dart';
import 'package:shady_example/interactive/interactive_gallery.dart';

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
        child: ShadyInteractives(),
      ),
    );
  }
}
