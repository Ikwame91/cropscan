import 'package:cropscan_pro/providers/naviagtion_provider.dart';
import 'package:cropscan_pro/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class QuickActionsWidget extends StatelessWidget {
  final bool isNewUser;
  final int totalScans;

  const QuickActionsWidget({
    super.key,
    required this.isNewUser,
    required this.totalScans,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(height: 2.h),
          _buildActionGrid(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.flash_on,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quick Actions",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                isNewUser
                    ? "Start your farming journey"
                    : "Continue your crop monitoring",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = _getActionsForUser();

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) =>
          _buildActionCard(context, actions[index]),
    );
  }

  Widget _buildActionCard(BuildContext context, QuickAction action) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: action.color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleActionTap(context, action),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 8.w,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  action.title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  action.subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (action.badge != null) ...[
                  SizedBox(height: 1.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      action.badge!,
                      style: TextStyle(
                        color: action.color,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<QuickAction> _getActionsForUser() {
    if (isNewUser) {
      return [
        QuickAction(
          id: 'scan_first',
          title: 'Scan First Crop',
          subtitle: 'Start with your first crop scan',
          icon: Icons.camera_alt,
          color: Colors.green,
          badge: 'START HERE',
          navigationIndex: 1,
        ),
        QuickAction(
          id: 'view_tips',
          title: 'Farming Tips',
          subtitle: 'Learn essential farming practices',
          icon: Icons.lightbulb,
          color: Colors.orange,
          navigationIndex: null,
        ),
        QuickAction(
          id: 'tutorial',
          title: 'How to Scan',
          subtitle: 'Learn how to use the camera',
          icon: Icons.help,
          color: Colors.blue,
          navigationIndex: null,
        ),
        QuickAction(
          id: 'profile_setup',
          title: 'Setup Profile',
          subtitle: 'Add your farming details',
          icon: Icons.person_add,
          color: Colors.purple,
          navigationIndex: 4,
        ),
      ];
    } else {
      return [
        QuickAction(
          id: 'scan_crop',
          title: 'Scan Crop',
          subtitle: 'Check for diseases and health',
          icon: Icons.camera_alt,
          color: Colors.green,
          badge: totalScans < 5 ? 'CONTINUE' : null,
          navigationIndex: 1,
        ),
        QuickAction(
          id: 'view_history',
          title: 'Scan History',
          subtitle: 'View past scan results',
          icon: Icons.history,
          color: Colors.blue,
          badge: '$totalScans scans',
          navigationIndex: null,
        ),
        QuickAction(
          id: 'disease_library',
          title: 'Disease Guide',
          subtitle: 'Learn about crop diseases',
          icon: Icons.menu_book,
          color: Colors.red,
          navigationIndex: null,
        ),
        QuickAction(
          id: 'alerts',
          title: 'Crop Alerts',
          subtitle: 'Check farming notifications',
          icon: Icons.notifications,
          color: Colors.orange,
          navigationIndex: 3,
        ),
      ];
    }
  }

  void _handleActionTap(BuildContext context, QuickAction action) {
    final navigationProvider = context.read<NavigationProvider>();

    switch (action.id) {
      case 'scan_first':
      case 'scan_crop':
        if (action.navigationIndex != null) {
          navigationProvider.navigateToTab(action.navigationIndex!);
        }
        break;

      case 'view_history':
        _showScanHistoryBottomSheet(context);
        break;

      case 'tutorial':
        _showTutorialDialog(context);
        break;

      case 'view_tips':
        _showTipsBottomSheet(context);
        break;

      case 'disease_library':
        _showDiseaseLibraryBottomSheet(context);
        break;

      case 'profile_setup':
      case 'alerts':
        if (action.navigationIndex != null) {
          navigationProvider.navigateToTab(action.navigationIndex!);
        }
        break;
    }
  }

  void _showScanHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Scan History",
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "Navigate to Detection History for full details",
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.camera_alt,
                color: AppTheme.lightTheme.colorScheme.primary),
            SizedBox(width: 2.w),
            Text("How to Scan Crops"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTutorialStep(
                "1", "Point camera at crop leaf", Icons.center_focus_strong),
            SizedBox(height: 1.h),
            _buildTutorialStep("2", "Ensure good lighting", Icons.wb_sunny),
            SizedBox(height: 1.h),
            _buildTutorialStep("3", "Tap capture button", Icons.camera),
            SizedBox(height: 1.h),
            _buildTutorialStep("4", "Wait for AI analysis", Icons.psychology),
            SizedBox(height: 1.h),
            _buildTutorialStep(
                "5", "View results & recommendations", Icons.insights),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NavigationProvider>().navigateToTab(1);
            },
            child: Text("Start Scanning"),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Icon(icon, size: 20, color: AppTheme.lightTheme.colorScheme.primary),
        SizedBox(width: 2.w),
        Expanded(child: Text(text)),
      ],
    );
  }

  void _showTipsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                "Essential Farming Tips",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildQuickTip("💧", "Water early morning",
                      "Best time is 6-8 AM to reduce disease risk"),
                  _buildQuickTip("🌱", "Proper spacing",
                      "Give plants room to breathe and grow"),
                  _buildQuickTip("🍃", "Check leaves regularly",
                      "Early detection prevents spread"),
                  _buildQuickTip("🔄", "Rotate crops",
                      "Prevents soil depletion and diseases"),
                  _buildQuickTip("🌿", "Mulch around plants",
                      "Retains moisture and prevents weeds"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTip(String emoji, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color:
            AppTheme.lightTheme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDiseaseLibraryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                "Common Crop Diseases",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildDiseaseCard("🍅", "Tomato Early Blight",
                      "Dark spots with rings on leaves"),
                  _buildDiseaseCard(
                      "🍅", "Tomato Late Blight", "Water-soaked brown spots"),
                  _buildDiseaseCard(
                      "🌽", "Maize Leaf Spot", "Small oval spots on leaves"),
                  _buildDiseaseCard("🌶️", "Pepper Disease",
                      "Various leaf and fruit problems"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseCard(String emoji, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

class QuickAction {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final int? navigationIndex;

  const QuickAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    this.navigationIndex,
  });
}
