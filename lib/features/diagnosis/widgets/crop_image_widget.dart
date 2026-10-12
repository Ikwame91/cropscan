import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// The scanned photo. Tap to open a full-screen, pinch-to-zoom view.
class CropImageWidget extends StatelessWidget {
  final String imagePath;

  const CropImageWidget({super.key, required this.imagePath});

  Widget _placeholder() => Container(
        height: 30.h,
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
        ),
      );

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: InteractiveViewer(
            maxScale: 5,
            child: Image.file(
              File(imagePath),
              errorBuilder: (_, __, ___) => _placeholder(),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 30.h,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }
}
