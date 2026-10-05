import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelPredictionStatus { initial, loading, ready, predicting, error }

class TfLiteModelServices extends ChangeNotifier {
  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  List<String>? _labels;
  String? _errorMessage;
  ModelPredictionStatus _status = ModelPredictionStatus.initial;

  // Updated configuration constants for 17 classes
  static const String _modelPath = "assets/ml_models/converted_model.tflite";
  static const String _labelPath = "assets/ml_models/labels.txt";
  static const int _inputSize = 256;
  static const int _channels = 3;
  static const int _outputLength = 17; // ✅ Updated from 16 to 17

  // Improved thresholds for better accuracy
  static const double _highConfidenceThreshold =
      0.75; // Slightly lowered for real-world usage
  static const double _cropConfidenceThreshold =
      0.60; // Minimum confidence for crop detection
  static const double _notCropThreshold =
      0.50; // Threshold for "not_a_crop" class

  // Getters
  Interpreter? get interpreter => _interpreter;
  List<String>? get labels => _labels;
  String? get errorMessage => _errorMessage;
  ModelPredictionStatus get status => _status;
  bool get isReady => _status == ModelPredictionStatus.ready;

  void _setStatus(ModelPredictionStatus newStatus, {String? message}) {
    if (_status != newStatus) {
      _status = newStatus;
      _errorMessage = message;
      notifyListeners();
      log(
        "TFLiteModelServices: Status changed to $_status${message != null ? " - $message" : ""}",
      );
    }
  }

  Future<void> loadModelAndLabels() async {
    if (_status == ModelPredictionStatus.loading ||
        _status == ModelPredictionStatus.ready) {
      log("TFLiteModelServices: Model already loaded or loading");
      return;
    }

    _setStatus(ModelPredictionStatus.loading);

    try {
      // Load interpreter with improved error handling
      _interpreter = await Interpreter.fromAsset(_modelPath);
      log("TFLiteModelServices: Interpreter loaded successfully");

      // Create isolate interpreter for async inference
      _isolateInterpreter = await IsolateInterpreter.create(
        address: _interpreter!.address,
      );
      log("TFLiteModelServices: Isolate interpreter created");

      // Load and validate labels
      await _loadLabels();

      // Validate model dimensions
      await _validateModelDimensions();

      _setStatus(ModelPredictionStatus.ready);
      log("TFLiteModelServices: Model service initialized successfully with ${_labels!.length} classes");
    } catch (e) {
      await _cleanup();
      _setStatus(
        ModelPredictionStatus.error,
        message: "Initialization failed: ${_sanitizeError(e)}",
      );
      log("TFLiteModelServices: Initialization error - $e");
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(_labelPath);
      _labels = labelsData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();

      if (_labels!.isEmpty) {
        throw Exception("No valid labels found in $_labelPath");
      }

      // Validate that we have the expected number of labels
      if (_labels!.length != _outputLength) {
        log("WARNING: Expected $_outputLength labels, but found ${_labels!.length}");
      }

      // Check if "not_a_crop" label exists
      final hasNotCropLabel = _labels!.any((label) =>
          label.toLowerCase().contains('not_a_crop') ||
          label.toLowerCase().contains('not a crop'));

      if (!hasNotCropLabel) {
        log("WARNING: 'not_a_crop' label not found in labels");
      }

      log('TFLiteModelServices: Loaded ${_labels!.length} labels: ${_labels!.join(", ")}');
    } catch (e) {
      throw Exception("Failed to load labels: ${_sanitizeError(e)}");
    }
  }

  Future<void> _validateModelDimensions() async {
    try {
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();

      if (inputTensors.isEmpty || outputTensors.isEmpty) {
        throw Exception("Model has invalid tensor configuration");
      }

      final inputShape = inputTensors[0].shape;
      final outputShape = outputTensors[0].shape;

      log("TFLiteModelServices: Input shape: $inputShape, Output shape: $outputShape");

      // Validate input shape [batch, height, width, channels]
      if (inputShape.length != 4 ||
          inputShape[1] != _inputSize ||
          inputShape[2] != _inputSize ||
          inputShape[3] != _channels) {
        throw Exception(
          "Model input shape $inputShape doesn't match expected [1, $_inputSize, $_inputSize, $_channels]",
        );
      }

      // Validate output shape [batch, classes]
      if (outputShape.length != 2 || outputShape[1] != _outputLength) {
        throw Exception(
          "Model output shape $outputShape doesn't match expected [1, $_outputLength]",
        );
      }

      log("TFLiteModelServices: Model dimensions validated successfully");
    } catch (e) {
      throw Exception("Model validation failed: ${_sanitizeError(e)}");
    }
  }

  Future<Map<String, dynamic>?> predictImage(File imageFile) async {
    if (!isReady || _isolateInterpreter == null) {
      throw Exception("Model not ready. Call loadModelAndLabels() first");
    }

    _setStatus(ModelPredictionStatus.predicting);

    try {
      log("TFLiteModelServices: Starting prediction for ${imageFile.path}");

      // Validate image file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception("Image file does not exist");
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception("Image file is empty");
      }

      // Preprocess image efficiently
      final inputTensor = await _preprocessImage(imageFile);
      log("TFLiteModelServices: Image preprocessed successfully");

      // Run inference
      final outputBuffer = List.filled(
        _outputLength,
        0.0,
      ).reshape([1, _outputLength]);

      await _isolateInterpreter!.run(inputTensor, outputBuffer);
      log("TFLiteModelServices: Inference completed");

      // Process results with improved logic
      final result = _processInferenceResults(outputBuffer[0]);

      _setStatus(ModelPredictionStatus.ready);

      log(
        "TFLiteModelServices: Prediction complete - ${result['label']}: ${(result['confidence'] * 100).toStringAsFixed(1)}% (isLikelyCrop: ${result['isLikelyCrop']}, isConfident: ${result['isConfident']})",
      );

      return result;
    } catch (e) {
      _setStatus(
        ModelPredictionStatus.error,
        message: "Prediction failed: ${_sanitizeError(e)}",
      );
      log("TFLiteModelServices: Prediction error - $e");
      rethrow;
    }
  }

  Future<List<dynamic>> _preprocessImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception(
            "Failed to decode image - unsupported format or corrupted file");
      }

      // Handle alpha channel properly
      var processedImage = originalImage;
      if (processedImage.hasAlpha) {
        // Create white background
        final background =
            img.Image(width: originalImage.width, height: originalImage.height);
        img.fill(background, color: img.ColorRgb8(255, 255, 255));

        // Composite the original image onto the white background
        processedImage = img.copyResize(
          background,
          width: originalImage.width,
          height: originalImage.height,
        );
        img.compositeImage(processedImage, originalImage);
      }

      // Resize with high-quality interpolation
      final resizedImage = img.copyResize(
        processedImage,
        width: _inputSize,
        height: _inputSize,
        interpolation: img.Interpolation.cubic,
      );

      // Efficient tensor creation with proper normalization
      final inputData = Float32List(_inputSize * _inputSize * _channels);
      int index = 0;

      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          // Normalize pixel values to [0, 1] range for Pbetter model performance
          inputData[index++] = pixel.r.toDouble();
          inputData[index++] = pixel.g.toDouble();
          inputData[index++] = pixel.b.toDouble();
        }
      }

      return inputData.reshape([1, _inputSize, _inputSize, _channels]);
    } catch (e) {
      throw Exception("Image preprocessing failed: ${_sanitizeError(e)}");
    }
  }

  Map<String, dynamic> _processInferenceResults(List<double> probabilities) {
    try {
      // Find the class with highest probability
      double maxConfidence = 0.0;
      int predictedIndex = -1;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          predictedIndex = i;
        }
      }

      // Get the predicted label
      String predictedLabel = "Unknown";
      if (predictedIndex >= 0 &&
          _labels != null &&
          predictedIndex < _labels!.length) {
        predictedLabel = _labels![predictedIndex];
      }

      // Enhanced logic for handling "not_a_crop" predictions
      final bool isNotACropPrediction =
          predictedLabel.toLowerCase().contains('not_a_crop') ||
              predictedLabel.toLowerCase().contains('not a crop');

      // Determine if this is likely a crop or not
      bool isLikelyCrop;
      bool isConfident;
      String finalLabel;

      if (isNotACropPrediction) {
        // If model predicts "not_a_crop" with reasonable confidence
        if (maxConfidence >= _notCropThreshold) {
          isLikelyCrop = false;
          isConfident = maxConfidence >= _highConfidenceThreshold;
          finalLabel = "Not a crop";
        } else {
          // Low confidence "not_a_crop" - treat as uncertain
          isLikelyCrop = false;
          isConfident = false;
          finalLabel = "Uncertain detection";
        }
      } else {
        // Model predicts an actual crop class
        if (maxConfidence >= _cropConfidenceThreshold) {
          isLikelyCrop = true;
          isConfident = maxConfidence >= _highConfidenceThreshold;
          finalLabel = predictedLabel;
        } else {
          // Low confidence crop prediction
          isLikelyCrop = false;
          isConfident = false;
          finalLabel = "Uncertain detection";
        }
      }

      // Calculate additional metrics for debugging
      final secondHighestConfidence =
          _getSecondHighestConfidence(probabilities, predictedIndex);
      final confidenceGap = maxConfidence - secondHighestConfidence;

      // Create debug information
      final debugInfo = {
        'rawPredictedLabel': predictedLabel,
        'rawMaxConfidence': maxConfidence,
        'predictedIndex': predictedIndex,
        'secondHighestConfidence': secondHighestConfidence,
        'confidenceGap': confidenceGap,
        'isNotACropPrediction': isNotACropPrediction,
        'thresholds': {
          'cropConfidence': _cropConfidenceThreshold,
          'highConfidence': _highConfidenceThreshold,
          'notCropThreshold': _notCropThreshold,
        }
      };

      log("TFLiteModelServices: Processing results - Raw: $predictedLabel (${(maxConfidence * 100).toStringAsFixed(1)}%), Final: $finalLabel");

      return {
        'label': finalLabel,
        'confidence': maxConfidence,
        'isConfident': isConfident,
        'isLikelyCrop': isLikelyCrop,
        'debugInfo': debugInfo,
        'allProbabilities': Map.fromIterables(
          _labels ?? List.generate(_outputLength, (i) => 'Class_$i'),
          probabilities,
        ),
      };
    } catch (e) {
      log("TFLiteModelServices: Error processing inference results - $e");
      return {
        'label': 'Processing Error',
        'confidence': 0.0,
        'isConfident': false,
        'isLikelyCrop': false,
        'error': _sanitizeError(e),
      };
    }
  }

  double _getSecondHighestConfidence(
      List<double> probabilities, int excludeIndex) {
    double secondMax = 0.0;
    for (int i = 0; i < probabilities.length; i++) {
      if (i != excludeIndex && probabilities[i] > secondMax) {
        secondMax = probabilities[i];
      }
    }
    return secondMax;
  }

  String _sanitizeError(dynamic error) {
    final errorStr = error.toString();
    final parts = errorStr.split(':');
    return parts.length > 1 ? parts.last.trim() : errorStr;
  }

  Future<void> _cleanup() async {
    try {
      _isolateInterpreter?.close();
      _isolateInterpreter = null;
      _interpreter?.close();
      _interpreter = null;
      _labels = null;
      log("TFLiteModelServices: Resources cleaned up");
    } catch (e) {
      log("TFLiteModelServices: Error during cleanup - $e");
    }
  }

  @override
  void dispose() {
    _cleanup();
    _setStatus(ModelPredictionStatus.initial);
    log("TFLiteModelServices: Service disposed");
    super.dispose();
  }
}
