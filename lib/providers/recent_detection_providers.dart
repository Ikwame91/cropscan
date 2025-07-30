import 'package:flutter/foundation.dart';
import '../models/crop_detection.dart';

class RecentDetectionsProvider extends ChangeNotifier {
  // Private list to hold recent detections
  List<CropDetection> _recentDetections = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Public getters to access the state
  List<CropDetection> get recentDetections => _recentDetections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: Optionally fetch initial data
  RecentDetectionsProvider() {
    fetchRecentDetections();
  }

  // Method to fetch recent detections (simulated API call for now)
  Future<void> fetchRecentDetections() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify UI that loading has started

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock data for demonstration. In a real app, this would come from an API.
      _recentDetections = [
        CropDetection(
          id: "det_001",
          cropName: "Bell Pepper",
          confidence: 94.5,
          imageUrl:
              "https://images.pexels.com/photos/594137/pexels-photo-594137.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
          status: "Healthy",
        ),
        CropDetection(
          id: "det_002",
          cropName: "Tomato",
          confidence: 89.2,
          imageUrl:
              "https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          detectedAt: DateTime.now().subtract(const Duration(hours: 5)),
          status: "Disease Detected",
        ),
        CropDetection(
          id: "det_003",
          cropName: "Maize",
          confidence: 96.8,
          imageUrl:
              "https://images.pexels.com/photos/547263/pexels-photo-547263.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          detectedAt: DateTime.now().subtract(const Duration(days: 1)),
          status: "Healthy",
        ),
        CropDetection(
          id: "det_004",
          cropName: "Potato",
          confidence: 75.1,
          imageUrl:
              "https://images.pexels.com/photos/2286794/pexels-photo-2286794.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          detectedAt: DateTime.now().subtract(const Duration(days: 3)),
          status: "Pest Detected",
        ),
      ];
      _errorMessage = null; // Clear any previous errors
    } catch (e) {
      _errorMessage = 'Failed to fetch detections: $e';
      _recentDetections = []; // Clear list on error
      if (kDebugMode) {
        print('Error fetching detections: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading has finished (or error occurred)
    }
  }

  // Method to add a new detection (e.g., after a successful scan)
  void addDetection(CropDetection newDetection) {
    // Add to the beginning of the list to show most recent first
    _recentDetections.insert(0, newDetection);
    notifyListeners(); // Notify UI to rebuild
    // In a real app, you'd also send this to your backend here
  }

  // Example: Remove a detection (if needed)
  void removeDetection(String id) {
    _recentDetections.removeWhere((detection) => detection.id == id);
    notifyListeners();
    // In a real app, you'd also send this to your backend
  }

  // You can add more methods here for filtering, sorting, etc.
}
