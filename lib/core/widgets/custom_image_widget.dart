import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomImageWidget extends StatelessWidget {
  final String? imageUrl; // Keep it nullable as you declared
  final double width;
  final double height;
  final BoxFit fit;

  /// Optional widget to show when the image fails to load.
  /// If null, a default asset image is shown.
  final Widget? errorWidget;

  const CustomImageWidget({
    super.key,
    required this.imageUrl, // Still required, but can be null
    this.width = 60,
    this.height = 60,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  static const String _defaultErrorAsset = "assets/images/no-image.jpg";

  bool _isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Widget _buildErrorPlaceholder() {
    return errorWidget ??
        Image.asset(
          _defaultErrorAsset,
          fit: fit,
          width: width,
          height: height,
        );
  }

  @override
  Widget build(BuildContext context) {
    final String effectiveImageUrl = imageUrl ?? '';
    final bool isNetwork = _isNetworkImage(effectiveImageUrl);
    final bool isAsset = effectiveImageUrl.startsWith('assets/');
    final bool isInvalidOrEmpty = effectiveImageUrl.isEmpty;

    if (isInvalidOrEmpty) {
      return _buildErrorPlaceholder();
    } else if (isNetwork) {
      // If it's a network image
      return CachedNetworkImage(
        imageUrl: effectiveImageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      );
    } else if (isAsset) {
      return Image.asset(
        effectiveImageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    } else {
      return _buildErrorPlaceholder();
    }
  }
}
