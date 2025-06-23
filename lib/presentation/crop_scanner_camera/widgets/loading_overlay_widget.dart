import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoadingOverlayWidget extends StatefulWidget {
  const LoadingOverlayWidget({super.key});

  @override
  State<LoadingOverlayWidget> createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<LoadingOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late Animation<double> _spinAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _spinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _spinController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation:
                    Listenable.merge([_spinController, _pulseController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _spinAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'agriculture',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 10.w,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 4.h),
              Text(
                'Analyzing Crop...',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'AI is processing your image',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 3.h),
              _buildProgressSteps(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Column(
      children: [
        _buildProgressStep('Capturing Image', true),
        SizedBox(height: 1.h),
        _buildProgressStep('Processing with AI', true),
        SizedBox(height: 1.h),
        _buildProgressStep('Identifying Crop', false),
      ],
    );
  }

  Widget _buildProgressStep(String title, bool isCompleted) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4.w,
          height: 4.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.white.withValues(alpha: 0.3),
          ),
          child: isCompleted
              ? Center(
                  child: CustomIconWidget(
                    iconName: 'check',
                    color: Colors.white,
                    size: 2.5.w,
                  ),
                )
              : null,
        ),
        SizedBox(width: 3.w),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: isCompleted
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
            fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
