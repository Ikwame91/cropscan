import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatefulWidget {
  final VoidCallback onSaveToFavorites;
  final VoidCallback onShareResults;
  final VoidCallback onScanAnother;

  const ActionButtonsWidget({
    super.key,
    required this.onSaveToFavorites,
    required this.onShareResults,
    required this.onScanAnother,
  });

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  bool _isFavorited = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    widget.onSaveToFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary Action Buttons Row
        Row(
          children: [
            // Save to Favorites Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _toggleFavorite,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: CustomIconWidget(
                    key: ValueKey(_isFavorited),
                    iconName: _isFavorited ? 'favorite' : 'favorite_border',
                    color: _isFavorited
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                label: Text(
                  _isFavorited ? 'Favorited' : 'Save',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: _isFavorited
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  side: BorderSide(
                    color: _isFavorited
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Share Results Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onShareResults,
                icon: CustomIconWidget(
                  iconName: 'share',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                label: Text(
                  'Share',
                  style: AppTheme.lightTheme.textTheme.labelLarge,
                ),
                style: AppTheme.lightTheme.outlinedButtonTheme.style?.copyWith(
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Scan Another Button (Primary CTA)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onScanAnother,
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            label: Text(
              'Scan Another Crop',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
              ),
              elevation: WidgetStateProperty.all(4.0),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Secondary Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // View History Button
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/detection-history'),
              icon: CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
              label: Text(
                'History',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),

            // Weather Dashboard Button
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/weather-dashboard'),
              icon: CustomIconWidget(
                iconName: 'wb_sunny',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
              label: Text(
                'Weather',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),

            // Dashboard Button
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/dashboard-home'),
              icon: CustomIconWidget(
                iconName: 'dashboard',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
              label: Text(
                'Dashboard',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
