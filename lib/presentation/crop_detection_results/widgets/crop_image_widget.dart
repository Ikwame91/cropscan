import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CropImageWidget extends StatelessWidget {
  final String imageUrl; // Can now be a local path or a network URL
  final bool
      isFromFile; // New property: true if it's a local file, false if network
  final VoidCallback? onImageTap;
  final VoidCallback? onLongPress;

  const CropImageWidget({
    super.key,
    required this.imageUrl,
    this.isFromFile = false, // Default to false for backward compatibility
    this.onImageTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (isFromFile) {
      // Load image from local file path
      imageWidget = Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 30.h, // Or whatever height you prefer
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 30.h,
            color: Colors.grey[300],
            child: Center(
              child:
                  Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
            ),
          );
        },
      );
    } else {
      // Load image from network URL (your previous implementation)
      imageWidget = CachedNetworkImage(
        // Assuming you use cached_network_image
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 30.h,
        placeholder: (context, url) => Container(
          height: 30.h,
          color: Colors.grey[300],
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 30.h,
          color: Colors.grey[300],
          child: Center(child: Icon(Icons.error, size: 50, color: Colors.red)),
        ),
      );
    }

    return GestureDetector(
      onTap: onImageTap,
      onLongPress: onLongPress,
      child: Container(
        height: 30.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          // You might add borderRadius or other decorations here
        ),
        child: ClipRRect(
          // Optional: If you want rounded corners
          borderRadius: BorderRadius.circular(10), // Example
          child: imageWidget,
        ),
      ),
    );
  }
}
