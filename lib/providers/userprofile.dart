// filepath: c:\flutter_projects\final_year_project_ui\cropscan_pro\lib\providers\user_profile_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // App settings
  bool _isHapticFeedback = true;
  bool _isSaveToGallery = false;
  String _selectedLanguage = "English";

  // Getters
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isHapticFeedback => _isHapticFeedback;
  bool get isSaveToGallery => _isSaveToGallery;
  String get selectedLanguage => _selectedLanguage;

  // Profile getters with defaults
  String get userName => _userProfile?.name ?? 'Local Farmer';
  String get userRegion => _userProfile?.region ?? 'Ghana';
  String? get profileImagePath => _userProfile?.profileImagePath;
  List<String> get primaryCrops => _userProfile?.primaryCrops ?? [];

  UserProfileProvider() {
    loadUserProfile();
    loadAppSettings();
  }

  // Initialize user profile (first time users)
  Future<void> initializeProfile({
    String name = 'Local Farmer',
    String region = 'Ghana',
  }) async {
    final now = DateTime.now();
    _userProfile = UserProfile(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      region: region,
      createdAt: now,
      lastUpdated: now,
    );

    await _saveUserProfile();
    notifyListeners();
  }

  // Load user profile from storage
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_profile.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> profileMap = json.decode(jsonString);
        _userProfile = UserProfile.fromMap(profileMap);
        debugPrint("✅ User profile loaded: ${_userProfile!.name}");
      } else {
        // Create default profile for first-time users
        await initializeProfile();
        debugPrint("📝 Created default user profile");
      }
    } catch (e) {
      debugPrint("❌ Error loading user profile: $e");
      _errorMessage = 'Failed to load profile: $e';
      // Create fallback profile
      await initializeProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save user profile to storage
  Future<void> _saveUserProfile() async {
    if (_userProfile == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_profile.json');

      final updatedProfile = _userProfile!.copyWith(
        lastUpdated: DateTime.now(),
      );
      _userProfile = updatedProfile;

      await file.writeAsString(updatedProfile.toJson());
      debugPrint("✅ User profile saved: ${updatedProfile.name}");
    } catch (e) {
      debugPrint("❌ Error saving user profile: $e");
      _errorMessage = 'Failed to save profile: $e';
      notifyListeners();
    }
  }

  // Update profile information
  Future<void> updateProfile({
    String? name,
    String? region,
    String? phoneNumber,
    String? farmSize,
    List<String>? primaryCrops,
  }) async {
    if (_userProfile == null) return;

    try {
      _userProfile = _userProfile!.copyWith(
        name: name,
        region: region,
        phoneNumber: phoneNumber,
        farmSize: farmSize,
        primaryCrops: primaryCrops,
        lastUpdated: DateTime.now(),
      );

      await _saveUserProfile();
      debugPrint("✅ Profile updated successfully");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error updating profile: $e");
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
    }
  }

  // Update profile picture
  Future<void> updateProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        // Save image to permanent storage
        final savedImagePath = await _saveProfileImagePermanently(image.path);

        if (_userProfile != null) {
          // Delete old profile image if exists
          if (_userProfile!.profileImagePath != null) {
            final oldImageFile = File(_userProfile!.profileImagePath!);
            if (await oldImageFile.exists()) {
              await oldImageFile.delete();
            }
          }

          _userProfile = _userProfile!.copyWith(
            profileImagePath: savedImagePath,
            lastUpdated: DateTime.now(),
          );

          await _saveUserProfile();
          debugPrint("✅ Profile picture updated");
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("❌ Error updating profile picture: $e");
      _errorMessage = 'Failed to update profile picture: $e';
      notifyListeners();
    }
  }

  // Save profile image to permanent storage
  Future<String> _saveProfileImagePermanently(String tempImagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${directory.path}/profile_images');

      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final originalFile = File(tempImagePath);
      if (!await originalFile.exists()) {
        throw Exception('Source image file does not exist');
      }

      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = '${profileDir.path}/$fileName';

      await originalFile.copy(newPath);
      debugPrint("✅ Profile image saved: $newPath");

      return newPath;
    } catch (e) {
      debugPrint("❌ Error saving profile image: $e");
      throw e;
    }
  }

  // App Settings Management
  Future<void> loadAppSettings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/app_settings.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> settings = json.decode(jsonString);

        _isHapticFeedback = settings['isHapticFeedback'] ?? true;
        _isSaveToGallery = settings['isSaveToGallery'] ?? false;
        _selectedLanguage = settings['selectedLanguage'] ?? 'English';

        debugPrint("✅ App settings loaded");
      }
    } catch (e) {
      debugPrint("❌ Error loading app settings: $e");
    }
  }

  Future<void> _saveAppSettings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/app_settings.json');

      final settings = {
        'isHapticFeedback': _isHapticFeedback,
        'isSaveToGallery': _isSaveToGallery,
        'selectedLanguage': _selectedLanguage,
      };

      await file.writeAsString(json.encode(settings));
      debugPrint("✅ App settings saved");
    } catch (e) {
      debugPrint("❌ Error saving app settings: $e");
    }
  }

  // Update app settings
  Future<void> updateHapticFeedback(bool value) async {
    _isHapticFeedback = value;
    await _saveAppSettings();
    notifyListeners();
  }

  Future<void> updateSaveToGallery(bool value) async {
    _isSaveToGallery = value;
    await _saveAppSettings();
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _selectedLanguage = language;
    await _saveAppSettings();
    notifyListeners();
  }

  // Clear all user data
  Future<void> clearAllData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // Delete profile image
      if (_userProfile?.profileImagePath != null) {
        final imageFile = File(_userProfile!.profileImagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      // Delete profile file
      final profileFile = File('${directory.path}/user_profile.json');
      if (await profileFile.exists()) {
        await profileFile.delete();
      }

      // Delete settings file
      final settingsFile = File('${directory.path}/app_settings.json');
      if (await settingsFile.exists()) {
        await settingsFile.delete();
      }

      // Reset to defaults
      _userProfile = null;
      _isHapticFeedback = true;
      _isSaveToGallery = false;
      _selectedLanguage = 'English';

      // Reinitialize
      await initializeProfile();

      debugPrint("✅ All user data cleared");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error clearing user data: $e");
      _errorMessage = 'Failed to clear data: $e';
      notifyListeners();
    }
  }
}
