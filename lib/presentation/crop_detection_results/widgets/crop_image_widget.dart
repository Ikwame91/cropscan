import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CropImageWidget extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onImageTap;
  final VoidCallback onLongPress;

  const CropImageWidget({
    super.key,
    required this.imageUrl,
    required this.onImageTap,
    required this.onLongPress,
  });

  @override
  State<CropImageWidget> createState() => _CropImageWidgetState();
}

class _CropImageWidgetState extends State<CropImageWidget>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    Matrix4 endMatrix;
    if (_transformationController.value != Matrix4.identity()) {
      endMatrix = Matrix4.identity();
    } else {
      endMatrix = Matrix4.identity()..scale(2.0);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
        CurveTween(curve: Curves.easeInOut).animate(_animationController));

    _animationController.forward(from: 0).then((_) {
      _transformationController.value = endMatrix;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 35.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GestureDetector(
          onTap: widget.onImageTap,
          onLongPress: widget.onLongPress,
          onDoubleTap: _onDoubleTap,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_animation != null) {
                _transformationController.value = _animation!.value;
              }
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 4.0,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomImageWidget(
                    imageUrl: widget.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
