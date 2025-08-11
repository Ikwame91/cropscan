import 'package:flutter/foundation.dart';
import '../models/farming_alert.dart';

class FarmingAlertsProvider extends ChangeNotifier {
  // Private list to hold farming alerts
  List<FarmingAlert> _farmingAlerts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Public getters to access the state
  List<FarmingAlert> get farmingAlerts => _farmingAlerts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get unread alerts count
  int get unreadAlertsCount =>
      _farmingAlerts.where((alert) => !alert.isRead).length;

  // Constructor: Optionally fetch initial data
  FarmingAlertsProvider() {
    fetchFarmingAlerts();
  }

  // Method to fetch farming alerts (simulated API call for now)
  Future<void> fetchFarmingAlerts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify UI that loading has started

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration. In a real app, this would come from an API.
      _farmingAlerts = [
        // Disease detection alerts
        FarmingAlert(
          id: "alert_001",
          title: "🍅 Tomato Disease Alert",
          message:
              "Early blight detected in tomato field. Apply fungicide treatment and remove affected leaves immediately.",
          priority: "critical",
          type: "disease",
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          isRead: false,
        ),
        FarmingAlert(
          id: "alert_002",
          title: "🌽 Corn Rust Warning",
          message:
              "Common rust spotted on corn plants in Field B. Consider applying rust-resistant varieties.",
          priority: "high",
          type: "disease",
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        FarmingAlert(
          id: "alert_003",
          title: "🫑 Pepper Bacterial Spot",
          message:
              "Bacterial spot detected on bell peppers. Remove affected plants and apply copper-based bactericide.",
          priority: "critical",
          type: "disease",
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          isRead: false,
        ),
        FarmingAlert(
          id: "alert_004",
          title: "🕷️ Spider Mite Infestation",
          message:
              "Two-spotted spider mites found on tomato plants. Apply miticide and increase humidity levels.",
          priority: "high",
          type: "pest",
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          isRead: true,
        ),
        FarmingAlert(
          id: "alert_005",
          title: "🍃 Corn Leaf Blight Alert",
          message:
              "Northern leaf blight detected in corn section. Use resistant varieties and fungicide treatment.",
          priority: "high",
          type: "disease",
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          isRead: false,
        ),
        FarmingAlert(
          id: "alert_006",
          title: "🦠 Tomato Virus Warning",
          message:
              "Yellow leaf curl virus detected. Remove infected plants and control whitefly vectors immediately.",
          priority: "critical",
          type: "virus",
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          isRead: false,
        ),
        FarmingAlert(
          id: "alert_007",
          title: "✅ Healthy Crop Update",
          message:
              "Great news! Your recent scans show healthy tomato and pepper plants in Field A.",
          priority: "low",
          type: "health",
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        FarmingAlert(
          id: "alert_008",
          title: "💧 Irrigation Reminder",
          message:
              "Based on recent disease detections, ensure proper drainage to prevent fungal growth.",
          priority: "medium",
          type: "irrigation",
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          isRead: false,
        ),
      ];
      _errorMessage = null; // Clear any previous errors
    } catch (e) {
      _errorMessage = 'Failed to fetch alerts: $e';
      _farmingAlerts = []; // Clear list on error
      if (kDebugMode) {
        print('Error fetching alerts: $e');
      } // For debugging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to mark an alert as read
  Future<void> markAlertAsRead(String alertId) async {
    try {
      // Optimistic UI update: update locally first
      final index = _farmingAlerts.indexWhere((alert) => alert.id == alertId);
      if (index != -1) {
        _farmingAlerts[index].isRead = true;
        notifyListeners(); // Update UI immediately

        // Simulate API call to persist the change
        await Future.delayed(const Duration(milliseconds: 500));
        // In a real app, send this update to Firebase/backend here.
        // If the backend call fails, you might want to revert the `isRead` status
        // and show an error message.
      }
    } catch (e) {
      // Handle error, maybe revert the UI change if API call fails
      print('Error marking alert as read: $e');
      // If API call failed, you might revert:
      // final index = _farmingAlerts.indexWhere((alert) => alert.id == alertId);
      // if (index != -1) {
      //   _farmingAlerts[index].isRead = false;
      //   notifyListeners();
      // }
      // Show an error message to the user
    }
  }

  // Example: Add a new alert (if needed, e.g., from backend push)
  void addAlert(FarmingAlert newAlert) {
    _farmingAlerts.insert(0, newAlert); // Add to the beginning
    notifyListeners();
    // No backend call here, as this would typically be a received alert
  }

  // Example: Snooze an alert
  Future<void> snoozeAlert(String alertId) async {
    // Implement snooze logic (e.g., temporarily hide or change status)
    // This might involve updating a `snoozedUntil` timestamp in the model
    // and persisting that to the backend.
    print('Snoozing alert $alertId');
    // For now, let's just remove it for demonstration
    _farmingAlerts.removeWhere((alert) => alert.id == alertId);
    notifyListeners();
    //  Send snooze status to backend
  }

  // You can add more methods here for filtering, archiving, etc.
}
