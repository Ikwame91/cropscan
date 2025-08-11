# 🌱 CropScan Pro

**AI-Powered Crop Disease Detection & Agricultural Management System**

CropScan Pro is a cutting-edge Flutter mobile application that leverages artificial intelligence and machine learning to help farmers identify crop diseases, monitor plant health, and receive actionable farming insights through simple smartphone photography.

## 🎯 Project Overview

This final year project aims to democratize agricultural expertise by providing farmers with instant access to AI-powered crop analysis. Simply point your camera at a crop, and our TensorFlow Lite model will identify the plant species, detect potential diseases, and provide comprehensive treatment recommendations.

### 🌟 Key Features

- **🤖 AI-Powered Crop Detection**: Advanced TensorFlow Lite integration for real-time plant identification
- **📸 Smart Camera Interface**: Intuitive camera controls with tap-to-focus, zoom, and flash functionality  
- **🔍 Disease Diagnosis**: Automated detection of common crop diseases and pests
- **📊 Confidence Scoring**: ML model confidence levels to ensure accurate diagnoses
- **💡 Treatment Recommendations**: Detailed guidance on fertilizers, pesticides, and care instructions
- **📱 Offline Capability**: Works without internet connectivity for remote farming areas
- **🌾 Multi-Crop Support**: Supports various crops including tomatoes, corn, peppers, and more
- **📋 Farming Alerts**: Real-time notifications for disease outbreaks, weather warnings, and care reminders
- **📈 Detection History**: Track your crop scans and monitor plant health over time
- **☁️ Weather Integration**: Location-based weather data for informed farming decisions

## 🏗️ Technology Stack

- **Frontend**: Flutter (^3.29.2) with Dart
- **AI/ML**: TensorFlow Lite for on-device inference
- **State Management**: Provider pattern for scalable state management
- **Camera**: Flutter Camera plugin with advanced controls
- **Image Processing**: Image picker and manipulation libraries
- **UI/UX**: Material Design 3 with custom theming
- **Responsive Design**: Sizer package for cross-platform compatibility

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK (API level 21+) / Xcode (iOS 11.0+)
- Device with camera capabilities

## 🛠️ Installation & Setup

1. **Clone the repository:**
```bash
git clone https://github.com/your-username/cropscan_pro.git
cd cropscan_pro
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure permissions:**
   - Camera permissions are automatically handled
   - Location permissions for weather features

4. **Run the application:**
```bash
flutter run
```

## 📁 Project Architecture

```
cropscan_pro/
├── android/                    # Android-specific configuration
├── ios/                        # iOS-specific configuration  
├── lib/
│   ├── core/
│   │   ├── app_export.dart     # Global exports and utilities
│   │   └── services/
│   │       └── tf_lite_model_services.dart  # ML model management
│   ├── models/
│   │   ├── crop_detection.dart           # Data models for crop detection
│   │   ├── farming_alert.dart           # Alert system models
│   │   └── crop_detection_args.dart     # Navigation arguments
│   ├── presentation/
│   │   ├── splash_screen/               # App initialization
│   │   ├── dashboard_home/              # Main dashboard
│   │   ├── crop_scanner_camera/         # AI camera interface
│   │   ├── crop_detection_results/      # Results and recommendations
│   │   ├── weather_dashboard/           # Weather integration
│   │   └── widgets/                     # Reusable UI components
│   ├── providers/
│   │   ├── navigation_provider.dart     # App navigation state
│   │   └── farming_alerts_provider.dart # Alerts management
│   ├── routes/                          # Application routing
│   ├── theme/                           # Custom theming
│   └── main.dart                        # Application entry point
├── assets/
│   ├── models/                          # TensorFlow Lite models
│   ├── images/                          # App icons and illustrations
│   └── fonts/                           # Custom typography
└── pubspec.yaml                         # Dependencies and configuration
```

## 🚀 Core Functionality

### 1. **Smart Crop Scanning**
```dart
// AI-powered image analysis
Future<Map<String, dynamic>?> detectCrop(File imageFile) async {
  final result = await tfliteModelServices.predictImage(imageFile);
  return result; // Returns crop type, confidence, and disease status
}
```

### 2. **Real-time Camera Interface**
- Live camera preview with detection frame overlay
- Gesture controls (pinch-to-zoom, tap-to-focus)
- Gallery integration for existing photos
- Optimized for various lighting conditions

### 3. **Intelligent Results Processing**
- Confidence threshold filtering
- Non-crop image detection
- Comprehensive treatment recommendations
- Shareable results and reports

## 🎨 User Experience

### **Intuitive Workflow:**
1. **Launch** → Open CropScan Pro
2. **Scan** → Point camera at crop or select from gallery  
3. **Analyze** → AI processes image in seconds
4. **Learn** → Receive detailed diagnosis and recommendations
5. **Act** → Follow treatment guidelines for optimal crop health

### **Smart Features:**
- **Low confidence warnings** for unclear images
- **Non-crop detection** to guide proper usage
- **Offline functionality** for remote areas
- **Multi-language support** (planned feature)

## 📱 Supported Platforms

- ✅ **Android**: API level 21+ (Android 5.0+)
- ✅ **iOS**: iOS 11.0+ (planned)
- ⏳ **Web**: Progressive Web App (future release)

## 🔧 Development Features

- **Hot reload** optimized camera management
- **Provider-based** state management for scalability
- **Modular architecture** for easy feature additions
- **Comprehensive error handling** and user feedback
- **Memory-optimized** image processing

## 📦 Deployment

### **Development Build:**
```bash
flutter run --debug
```

### **Production Build:**
```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

## 🌱 Impact & Vision

CropScan Pro aims to:
- **Reduce crop losses** through early disease detection
- **Democratize agricultural expertise** for small-scale farmers
- **Improve food security** through better crop management
- **Support sustainable farming** practices with data-driven insights

## 🤝 Contributing

This is a final year project, but feedback and suggestions are welcome:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is developed as part of academic research. For commercial use, please contact the development team.

## 🙏 Acknowledgments

- **TensorFlow Team** for TensorFlow Lite mobile ML framework
- **Flutter Team** for the amazing cross-platform framework
- **Agricultural Experts** who provided domain knowledge and dataset validation
- **Open Source Community** for invaluable tools and libraries

## 📞 Contact

- **Developer**: Kwame Agyapong & Bryan Sackey
- **Institution**: Kwame Nkrumah University of Science & Technology
- **Email**: Kwameagyapong91@gmail.com
- **Project Supervisor**: Dr Usiph

---

**Built with ❤️ for farmers worldwide**

*Empowering agriculture through artificial intelligence*
