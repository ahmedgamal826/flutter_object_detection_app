import 'package:flutter/material.dart';
import 'package:object_detection_app/home_page.dart';

void main() {
  runApp(const ObjectDetectionApp());
}

class ObjectDetectionApp extends StatelessWidget {
  const ObjectDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
