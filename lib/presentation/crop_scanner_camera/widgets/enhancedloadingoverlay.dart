import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Enhancedloadingoverlay extends StatefulWidget {
  final Duration? minimumDuration;
  const Enhancedloadingoverlay({
    super.key,
    this.minimumDuration = const Duration(seconds: 2),
  });

  @override
  State<Enhancedloadingoverlay> createState() => _EnhancedloadingoverlayState();
}

class _EnhancedloadingoverlayState extends State<Enhancedloadingoverlay>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentPhase = 0;
  final List<String> _phases = [
    "📸 Analyzing image...",
    "🤖 Running AI detection...",
    "📊 Processing results...",
  ];

  @override
  void initState() {
    super.initState();

    // Initialize the controller FIRST
    _progressController = AnimationController(
      duration: widget.minimumDuration ?? const Duration(seconds: 2),
      vsync: this,
    );

    // THEN create the animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));

    // FINALLY start the animation
    _startPhaseAnimation();
  }

  void _startPhaseAnimation() {
    _progressController.forward();

    // Change phases during animation
    Timer.periodic(
        Duration(
            milliseconds:
                (widget.minimumDuration!.inMilliseconds / _phases.length)
                    .round()), (timer) {
      if (mounted && _currentPhase < _phases.length - 1) {
        setState(() {
          _currentPhase++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated progress indicator
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _progressAnimation.value,
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  const Center(
                    child: Icon(
                      Icons.agriculture,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Phase text with animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _phases[_currentPhase],
                key: ValueKey(_currentPhase),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 1.h),

            // Progress percentage
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Text(
                  '${(_progressAnimation.value * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }
}
