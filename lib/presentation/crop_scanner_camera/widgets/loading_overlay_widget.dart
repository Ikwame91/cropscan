import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

import '../../../core/app_export.dart';

class LoadingOverlayWidget extends StatefulWidget {
  final VoidCallback? onTimeout;
  final int timeoutSeconds;

  const LoadingOverlayWidget({
    super.key,
    this.onTimeout,
    this.timeoutSeconds = 15, // 15 second timeout
  });

  @override
  State<LoadingOverlayWidget> createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<LoadingOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late Animation<double> _spinAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _timeoutTimer;
  Timer? _progressTimer;
  int _currentStep = 0;
  bool _hasTimedOut = false;

  final List<String> _steps = [
    'Capturing Image',
    'Processing with AI',
    'Identifying Crop',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _startProgressTimer();
    _startTimeoutTimer();

    debugPrint(
        "🔄 LoadingOverlay: Started with ${widget.timeoutSeconds}s timeout");
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

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_currentStep < _steps.length - 1) {
          _currentStep++;
          debugPrint("🔄 LoadingOverlay: Progress step $_currentStep");
        }
      });
    });
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(Duration(seconds: widget.timeoutSeconds), () {
      if (!mounted) return;

      debugPrint(
          "⏰ LoadingOverlay: Timeout reached after ${widget.timeoutSeconds}s");
      setState(() {
        _hasTimedOut = true;
      });

      if (widget.onTimeout != null) {
        widget.onTimeout!();
      }
    });
  }

  @override
  void dispose() {
    debugPrint("🔄 LoadingOverlay: Disposing");
    _timeoutTimer?.cancel();
    _progressTimer?.cancel();
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
              if (!_hasTimedOut) ...[
                // Normal loading animation
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
              ] else ...[
                // Timeout UI
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.red,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'error_outline',
                      color: Colors.red,
                      size: 10.w,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Processing Timeout',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'The AI took too long to process',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the loading overlay
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Column(
      children: [
        for (int i = 0; i < _steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < _steps.length - 1 ? 1.h : 0),
            child: _buildProgressStep(_steps[i], i <= _currentStep),
          ),
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
