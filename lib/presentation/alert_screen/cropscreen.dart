import 'package:cropscan_pro/presentation/alert_screen/widgets/crop_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:cropscan_pro/core/app_export.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final List<Map<String, dynamic>> _allCrops = [
    {
      "id": 1,
      "cropName": "Maize",
      "location": "North Field, 3.1 acres",
      "imageUrl":
          "https://images.pexels.com/photos/547263/pexels-photo-547263.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "health": 88,
      "harvestInDays": 65,
      "issues": 0,
      "expectedYield": 2.1,
      "scannedAgo": "3 hours ago",
      "status": "Healthy",
      "type": "Maize",
    },
    {
      "id": 2,
      "cropName": "Tomato",
      "location": "Greenhouse A, 0.8 acres",
      "imageUrl":
          "https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "health": 75,
      "harvestInDays": 25,
      "issues": 2,
      "expectedYield": 3.2,
      "scannedAgo": "1 day ago",
      "status": "Disease Detected",
      "type": "Tomato",
    },
    {
      "id": 3,
      "cropName": "Bell Pepper",
      "location": "Field 2, 1.5 acres",
      "imageUrl":
          "https://images.pexels.com/photos/594137/pexels-photo-594137.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "health": 94,
      "harvestInDays": 40,
      "issues": 0,
      "expectedYield": 1.5,
      "scannedAgo": "2 days ago",
      "status": "Healthy",
      "type": "Bell Pepper",
    },
    {
      "id": 4,
      "cropName": "Maize",
      "location": "South Field, 2.5 acres",
      "imageUrl":
          "https://images.pexels.com/photos/547263/pexels-photo-547263.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "health": 90,
      "harvestInDays": 70,
      "issues": 0,
      "expectedYield": 2.5,
      "scannedAgo": "5 hours ago",
      "status": "Healthy",
      "type": "Maize",
    },
  ];

  String _selectedCropType = 'All Crops';

  int get _healthyCropsCount {
    return _allCrops.where((crop) => crop["status"] == "Healthy").length;
  }

  int get _attentionNeededCropsCount {
    return _allCrops.where((crop) => crop["status"] != "Healthy").length;
  }

  // Filter crops based on _selectedCropType
  List<Map<String, dynamic>> get _filteredCrops {
    if (_selectedCropType == 'All Crops') {
      return _allCrops;
    } else {
      return _allCrops
          .where((crop) => crop["type"] == _selectedCropType)
          .toList();
    }
  }

  // Get unique crop types for the horizontal filter tabs
  List<String> get _cropTypes {
    final types =
        _allCrops.map((crop) => crop["type"] as String).toSet().toList();
    types.sort();
    return ['All Crops', ...types];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Crops',
                      style: GoogleFonts.poppins(
                        textStyle: AppTheme.lightTheme.textTheme.headlineMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      )),
                  GestureDetector(
                    onTap: () {
                      // Handle add new crop action
                      print('Add new crop field');
                    },
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('$_healthyCropsCount', 'Healthy Crops'),
                  _buildStatItem(
                      '$_attentionNeededCropsCount', 'Need Attention',
                      color: AppTheme.lightTheme.colorScheme.error),
                ],
              ),
            ],
          ),
        ),

        // Horizontal filter tabs
        Container(
          height: 6.h,
          padding: EdgeInsets.symmetric(horizontal: 3.5.w),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cropTypes.length,
            separatorBuilder: (context, index) => SizedBox(width: 2.w),
            itemBuilder: (context, index) {
              final cropType = _cropTypes[index];
              final isSelected = _selectedCropType == cropType;
              return ChoiceChip(
                label: Text(
                  cropType,
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.lightTheme.colorScheme.primary,
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.dividerColor,
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCropType = cropType;
                    });
                  }
                },
                padding: EdgeInsets.symmetric(horizontal: 4.w),
              );
            },
          ),
        ),

        SizedBox(height: 2.h),

        // List of Crop Cards (Filtered)
        Expanded(
          child: _filteredCrops.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'eco', // Or a more relevant icon
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 60,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No crops of this type found.',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Try selecting "All Crops" or add a new crop field.',
                        textAlign: TextAlign.center,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _filteredCrops.length,
                  itemBuilder: (context, index) {
                    final crop = _filteredCrops[index];
                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: 2.h), // Spacing between cards
                      child: CropCard(
                          crop: crop), // Use a separate CropCard widget
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Helper widget for the top statistics
  Widget _buildStatItem(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
              textStyle: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color ?? AppTheme.lightTheme.colorScheme.primary,
              ),
            )),
        Text(label,
            style: GoogleFonts.poppins(
              textStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            )),
      ],
    );
  }
}


// --- Separate Widget: CropCard ---
// It's highly recommended to extract the repeating card UI into its own widget
// for better readability, reusability, and maintainability.
// File: lib/presentation/my_crops_screen/widgets/crop_card.dart (create this file)



// --- REMINDER: Update your main_screen.dart to include this new tab ---
/*
// In lib/screens/main_screen.dart
import 'package:cropscan_pro/presentation/my_crops_screen/my_crops_screen.dart'; // Import it

// In _MainScreenState's initState:
_screens = [
  const DashboardHome(),
  const CropScannerCamera(),
  const WeatherDashboard(),
  const AlertScreen(),
  const MyCropsScreen(), // Add this here, assuming it's the 4th tab (index 4)
];

// And update your BottomNavigationBarItem for 'My Crops' accordingly
BottomNavigationBarItem(
  icon: CustomIconWidget(
    iconName: 'spa', // Or 'my_crops' if you have a custom icon
    color: _currentIndex == 4
        ? AppTheme.lightTheme.colorScheme.primary
        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
    size: 24,
  ),
  label: 'My Crops',
),
*/