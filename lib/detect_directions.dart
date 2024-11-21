import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class DetectDirections extends StatefulWidget {
  const DetectDirections({super.key});

  @override
  State<DetectDirections> createState() => _DetectDirectionsState();
}

class _DetectDirectionsState extends State<DetectDirections> {
  final ImagePicker imagePicker = ImagePicker();
  XFile? _image;
  File? file;
  var recognitions;
  String label = "";
  String confidence = "";
  List<String> knownLabels = [];

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
    loadLabels();
  }

  // Load the model
  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/directions_model.tflite",
      labels: "assets/directions_labels.txt",
    );
  }

  // Load labels from labels.txt file
  loadLabels() async {
    final labels = await rootBundle.loadString('assets/directions_labels.txt');
    setState(() {
      knownLabels =
          labels.split('\n'); // Split by line to get individual labels
    });
  }

  // Pick an image from the gallery
  Future<void> pickImage() async {
    try {
      final XFile? image =
          await imagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectImage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future detectImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (recognitions != null && recognitions.isNotEmpty) {
      // Sort the recognitions by confidence score (highest first)
      recognitions.sort((a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double));

      // Get the label and confidence score of the highest prediction
      var topRecognition = recognitions[0];

      // Check if the confidence is 100%
      if (topRecognition['confidence'] >= 0.99) {
        setState(() {
          label = topRecognition['label'] ?? "Unknown";
          confidence = (topRecognition['confidence'] * 100).toStringAsFixed(2);
        });
      } else {
        setState(() {
          label = "Neither Cat Nor Dog";
          confidence = "";
        });
      }
    } else {
      // If no recognitions found, display "No Label Found"
      setState(() {
        label = "No Label Found";
        confidence = "";
      });
    }
    print(recognitions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Directions Detection',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              const Text('Pick an image to identify'),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: pickImage,
              child: const Text(
                'Pick Image from Gallery',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              label.isNotEmpty
                  ? 'Label: $label\nConfidence: $confidence%'
                  : 'No result to display',
              style: const TextStyle(fontSize: 23),
            ),
          ],
        ),
      ),
    );
  }
}
