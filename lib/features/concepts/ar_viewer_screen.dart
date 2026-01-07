import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ArViewerScreen extends StatelessWidget {
  final String modelUrl;
  final String title;

  const ArViewerScreen({
    super.key, 
    required this.modelUrl, 
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ModelViewer(
        src: modelUrl, // The URL from Firebase
        alt: "A 3D model of $title",
        ar: true, // 🚀 ACTIVATES AR MODE
        autoRotate: true, // Makes the model spin slowly
        cameraControls: true, // Allows user to zoom/rotate
        backgroundColor: Colors.white,
      ),
    );
  }
}