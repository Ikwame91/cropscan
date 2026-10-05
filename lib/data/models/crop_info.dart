import 'package:flutter/material.dart';

class CropInfo {
  final String displayName;
  final String cropType;
  final String condition;
  final String description;
  final Color statusColor;
  final String recommendedAction;

  CropInfo({
    required this.displayName,
    required this.cropType,
    required this.condition,
    required this.description,
    required this.statusColor,
    required this.recommendedAction,
  });
}

class CropInfoMapper {
  static final Map<String, CropInfo> _cropDatabase = {
    'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot': CropInfo(
      displayName: 'Corn - Cercospora Leaf Spot',
      cropType: 'Corn (Maize)',
      condition: 'Disease Detected',
      description:
          'Cercospora leaf spot causes gray spots with dark borders on corn leaves.',
      statusColor: Colors.orange,
      recommendedAction:
          'Apply fungicide treatment and improve air circulation.',
    ),
    'Corn_(maize)___Common_rust_': CropInfo(
      displayName: 'Corn - Common Rust',
      cropType: 'Corn (Maize)',
      condition: 'Disease Detected',
      description:
          'Common rust appears as small, reddish-brown pustules on corn leaves.',
      statusColor: Colors.red,
      recommendedAction:
          'Apply rust-resistant varieties and fungicide if severe.',
    ),
    'Corn_(maize)___Northern_Leaf_Blight': CropInfo(
      displayName: 'Corn - Northern Leaf Blight',
      cropType: 'Corn (Maize)',
      condition: 'Disease Detected',
      description:
          'Northern leaf blight causes elliptical lesions on corn leaves.',
      statusColor: Colors.red,
      recommendedAction:
          'Use resistant varieties and apply fungicide treatment.',
    ),
    'Corn_(maize)___healthy': CropInfo(
      displayName: 'Corn - Healthy',
      cropType: 'Corn (Maize)',
      condition: 'Healthy',
      description:
          'Your corn appears to be in good health with no visible diseases.',
      statusColor: Colors.green,
      recommendedAction:
          'Continue current care practices and monitor regularly.',
    ),
    'Pepper__bell___Bacterial_spot': CropInfo(
      displayName: 'Bell Pepper - Bacterial Spot',
      cropType: 'Bell Pepper',
      condition: 'Disease Detected',
      description:
          'Bacterial spot causes dark, water-soaked lesions on pepper leaves and fruits.',
      statusColor: Colors.red,
      recommendedAction:
          'Remove affected plants and apply copper-based bactericide.',
    ),
    'Pepper__bell___healthy': CropInfo(
      displayName: 'Bell Pepper - Healthy',
      cropType: 'Bell Pepper',
      condition: 'Healthy',
      description: 'Your bell pepper appears healthy with no signs of disease.',
      statusColor: Colors.green,
      recommendedAction: 'Maintain proper watering and nutrition schedule.',
    ),
    'Tomato_Bacterial_spot': CropInfo(
      displayName: 'Tomato - Bacterial Spot',
      cropType: 'Tomato',
      condition: 'Disease Detected',
      description:
          'Bacterial spot causes small, dark lesions on tomato leaves and fruits.',
      statusColor: Colors.red,
      recommendedAction: 'Apply copper fungicide and improve air circulation.',
    ),
    'Tomato_Early_blight': CropInfo(
      displayName: 'Tomato - Early Blight',
      cropType: 'Tomato',
      condition: 'Disease Detected',
      description:
          'Early blight causes brown spots with concentric rings on tomato leaves.',
      statusColor: Colors.orange,
      recommendedAction:
          'Remove affected leaves and apply fungicide treatment.',
    ),
    'Tomato_Late_blight': CropInfo(
      displayName: 'Tomato - Late Blight',
      cropType: 'Tomato',
      condition: 'Disease Detected',
      description:
          'Late blight causes water-soaked lesions that turn brown and black.',
      statusColor: Colors.red,
      recommendedAction: 'Apply preventive fungicide and ensure good drainage.',
    ),
    'Tomato_Leaf_Mold': CropInfo(
      displayName: 'Tomato - Leaf Mold',
      cropType: 'Tomato',
      condition: 'Disease Detected',
      description:
          'Leaf mold appears as yellow spots on upper leaf surfaces with fuzzy growth below.',
      statusColor: Colors.orange,
      recommendedAction: 'Improve ventilation and reduce humidity levels.',
    ),
    'Tomato_Septoria_leaf_spot': CropInfo(
      displayName: 'Tomato - Septoria Leaf Spot',
      cropType: 'Tomato',
      condition: 'Disease Detected',
      description:
          'Septoria leaf spot causes small, circular spots with dark borders.',
      statusColor: Colors.orange,
      recommendedAction: 'Remove affected leaves and apply fungicide spray.',
    ),
    'Tomato_Spider_mites_Two_spotted_spider_mite': CropInfo(
      displayName: 'Tomato - Spider Mites',
      cropType: 'Tomato',
      condition: 'Pest Detected',
      description:
          'Two-spotted spider mites cause stippling and webbing on tomato leaves.',
      statusColor: Colors.red,
      recommendedAction: 'Apply miticide and increase humidity around plants.',
    ),
    'Tomato__Target_Spot': CropInfo(
      displayName: 'Tomato - Target Spot',
      cropType: 'Tomato',
      condition: 'Disease Detected',
      description:
          'Target spot causes brown lesions with concentric rings on leaves.',
      statusColor: Colors.orange,
      recommendedAction: 'Apply fungicide and remove affected plant debris.',
    ),
    'Tomato__Tomato_YellowLeaf__Curl_Virus': CropInfo(
      displayName: 'Tomato - Yellow Leaf Curl Virus',
      cropType: 'Tomato',
      condition: 'Virus Detected',
      description:
          'Yellow leaf curl virus causes upward curling and yellowing of leaves.',
      statusColor: Colors.red,
      recommendedAction: 'Remove infected plants and control whitefly vectors.',
    ),
    'Tomato__Tomato_mosaic_virus': CropInfo(
      displayName: 'Tomato - Mosaic Virus',
      cropType: 'Tomato',
      condition: 'Virus Detected',
      description:
          'Mosaic virus causes mottled light and dark green patterns on leaves.',
      statusColor: Colors.red,
      recommendedAction:
          'Remove infected plants and disinfect tools between uses.',
    ),
    'Tomato_healthy': CropInfo(
      displayName: 'Tomato - Healthy',
      cropType: 'Tomato',
      condition: 'Healthy',
      description:
          'Your tomato plant appears healthy with no visible diseases or pests.',
      statusColor: Colors.green,
      recommendedAction:
          'Continue regular watering and fertilization schedule.',
    ),
    'not_a_crop': CropInfo(
      displayName: 'Not a Crop',
      cropType: 'N/A',
      condition: 'Not a Crop',
      description: 'The image provided does not appear to be a crop.',
      statusColor: Colors.grey,
      recommendedAction: 'Please provide a clear image of a plant.',
    ),
  };

  static CropInfo getCropInfo(String rawLabel) {
    // First, try to get a specific, hard-coded entry.
    final cropInfo = _cropDatabase[rawLabel];
    if (cropInfo != null) {
      return cropInfo;
    }
    return CropInfo(
      displayName: _cleanDisplayName(rawLabel),
      cropType: _extractCropType(rawLabel),
      condition: _determineCondition(rawLabel),
      description: _generateDescription(rawLabel),
      statusColor: _getStatusColor(rawLabel),
      recommendedAction: _generateRecommendedAction(rawLabel),
    );
  }

  static String getRawLabel(String displayName) {
    String raw =
        displayName.replaceAll(' - ', '_').replaceAll(' ', '_').toLowerCase();
    if (raw.contains('corn')) {
      raw = raw.replaceAll('corn', 'corn_(maize)');
    }
    if (!raw.contains('___') && !raw.contains('healthy')) {
      final parts = raw.split('_');
      if (parts.length > 2) {
        raw = '${parts[0]}_${parts[1]}___${parts.sublist(2).join('_')}';
      }
    }
    return raw; // e.g., "tomato_healthy" for "Tomato - Healthy"
  }

  static String _cleanDisplayName(String rawLabel) {
    return rawLabel
        .replaceAll('_', ' ')
        .replaceAll('(maize)', '')
        .replaceAll('  ', ' ')
        .trim()
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  static String _extractCropType(String rawName) {
    return rawName.split('_')[0].replaceAll('(', ' (');
  }

  static String _determineCondition(String rawName) {
    if (rawName.toLowerCase().contains('healthy')) {
      return 'Healthy';
    } else if (rawName.toLowerCase().contains('blight') ||
        rawName.toLowerCase().contains('rust') ||
        rawName.toLowerCase().contains('spot') ||
        rawName.toLowerCase().contains('mold') ||
        rawName.toLowerCase().contains('virus') ||
        rawName.toLowerCase().contains('cercospora')) {
      return 'Disease Detected';
    } else if (rawName.toLowerCase().contains('mite')) {
      return 'Pest Detected';
    } else if (rawName.toLowerCase().contains('not_a_crop')) {
      return 'Not a Crop';
    } else {
      return 'Needs Attention';
    }
  }

  static String _generateDescription(String rawName) {
    final condition = _determineCondition(rawName);
    final cropType = _extractCropType(rawName);

    switch (condition) {
      case 'Healthy':
        return 'Your $cropType appears to be in good health with no visible signs of disease or pest damage.';
      case 'Disease Detected':
        return 'Disease symptoms detected in your $cropType. Early intervention is recommended.';
      case 'Pest Detected':
        return 'Pest activity detected on your $cropType. Consider appropriate pest control measures.';
      case 'Not a Crop':
        return 'The image provided does not appear to be a crop. Please provide a clear image of a plant.';
      default:
        return 'Your $cropType may require attention. Monitor closely for any changes.';
    }
  }

  static String _generateRecommendedAction(String rawName) {
    final condition = _determineCondition(rawName);

    switch (condition) {
      case 'Healthy':
        return 'Continue regular care and monitoring. Maintain current watering and fertilization schedule.';
      case 'Disease Detected':
        return 'Apply appropriate fungicide, improve air circulation, and remove affected plant parts if necessary.';
      case 'Pest Detected':
        return 'Apply organic or chemical pest control methods. Check neighboring plants for similar issues.';
      case 'Not a Crop':
        return 'Try taking a new photo, ensuring the plant is clearly visible and well-lit.';
      default:
        return 'Monitor the plant closely and consult with local agricultural experts if symptoms persist.';
    }
  }

  static Color _getStatusColor(String rawName) {
    final condition = _determineCondition(rawName);

    switch (condition) {
      case 'Healthy':
        return Colors.green;
      case 'Disease Detected':
        return Colors.red;
      case 'Pest Detected':
        return Colors.orange;
      case 'Not a Crop':
        return Colors.grey;
      default:
        return Colors.amber;
    }
  }

  static CropInfo getDefaultInfo(String rawLabel) {
    return CropInfo(
      displayName: _cleanDisplayName(rawLabel),
      cropType: 'Unknown',
      condition: 'Detected',
      description: 'Crop detected but detailed information is not available.',
      statusColor: Colors.grey,
      recommendedAction:
          'Consult with agricultural expert for proper diagnosis.',
    );
  }
}
