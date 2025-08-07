import 'dart:developer';
import 'dart:math' as math;
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

  // Configuration constants
  static const String _modelPath = "assets/ml_models/converted_model.tflite";
  static const String _labelPath = "assets/ml_models/labels.txt";
  static const int _inputSize = 256;
  static const int _channels = 3;
  static const int _outputLength = 16;

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
      // Load interpreter
      _interpreter = await Interpreter.fromAsset(_modelPath);

      // Create isolate interpreter for async inference
      _isolateInterpreter = await IsolateInterpreter.create(
        address: _interpreter!.address,
      );

      // Load and validate labels
      await _loadLabels();

      // Validate model dimensions
      await _validateModelDimensions();

      _setStatus(ModelPredictionStatus.ready);
      log("TFLiteModelServices: Model service initialized successfully");
    } catch (e) {
      await _cleanup();
      _setStatus(
        ModelPredictionStatus.error,
        message: "Initialization failed: ${_sanitizeError(e)}",
      );
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    final labelsData = await rootBundle.loadString(_labelPath);
    _labels = labelsData
        .split('\n')
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList();

    if (_labels!.isEmpty) {
      throw Exception("No valid labels found in $_labelPath");
    }

    log('TFLiteModelServices: Loaded ${_labels!.length} labels');
  }

  Future<void> _validateModelDimensions() async {
    final inputTensors = _interpreter!.getInputTensors();
    final outputTensors = _interpreter!.getOutputTensors();

    if (inputTensors.isEmpty || outputTensors.isEmpty) {
      throw Exception("Model has invalid tensor configuration");
    }

    final inputShape = inputTensors[0].shape;
    final outputShape = outputTensors[0].shape;

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

    if (_labels!.length != _outputLength) {
      log(
        "WARNING: Label count (${_labels!.length}) doesn't match output length ($_outputLength)",
      );
    }
  }

  Future<Map<String, dynamic>?> predictImage(File imageFile) async {
    if (!isReady || _isolateInterpreter == null) {
      throw Exception("Model not ready. Call loadModelAndLabels() first");
    }

    _setStatus(ModelPredictionStatus.predicting);

    try {
      // Preprocess image efficiently
      final inputTensor = await _preprocessImage(imageFile);

      // Run inference
      final outputBuffer = List.filled(
        _outputLength,
        0.0,
      ).reshape([1, _outputLength]);
      await _isolateInterpreter!.run(inputTensor, outputBuffer);

      // Process results
      final result = _processInferenceResults(outputBuffer[0]);

      _setStatus(ModelPredictionStatus.ready);

      log(
        "TFLiteModelServices: Prediction complete - ${result['label']}: ${(result['confidence'] * 100).toStringAsFixed(1)}%",
      );

      return result;
    } catch (e) {
      _setStatus(
        ModelPredictionStatus.error,
        message: "Prediction failed: ${_sanitizeError(e)}",
      );
      rethrow;
    }
  }

  Future<List<dynamic>> _preprocessImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception("Failed to decode image");
    }

    var processedImage = originalImage;
    if (processedImage.hasAlpha) {
      processedImage = img.copyResize(
        img.fill(
            img.Image(width: originalImage.width, height: originalImage.height),
            color: img.ColorRgb8(255, 255, 255)),
        width: originalImage.width,
        height: originalImage.height,
      );
      img.compositeImage(processedImage, originalImage);
    }
    final resizedImage = img.copyResize(
      originalImage,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.cubic,
    );

    // Efficient tensor creation using Float32List
    final inputData = Float32List(_inputSize * _inputSize * _channels);
    int index = 0;

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        inputData[index++] = pixel.r.toDouble();
        inputData[index++] = pixel.g.toDouble();
        inputData[index++] = pixel.b.toDouble();
      }
    }

    return inputData.reshape([1, _inputSize, _inputSize, _channels]);
  }

  Map<String, dynamic> _processInferenceResults(List<double> probabilities) {
    double maxConfidence = 0.0;
    int predictedIndex = -1;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        predictedIndex = i;
      }
    }

    // Calculate entropy for uncertainty detection
    double entropy = 0.0;
    for (double prob in probabilities) {
      if (prob > 0.0001) {
        entropy -= prob * (math.log(prob) / math.log(2));
      }
    }

    // Define four clear "fail" conditions that indicate a non-crop image.
    final bool hasUnrealisticConfidence =
        maxConfidence > 0.95 && !_hasReasonableDistribution(probabilities);
    final bool hasConfusion = _hasConfusedPrediction(probabilities);
    final bool hasFlatDistribution = entropy > 3.0;
    final bool isSuspiciouslyConfident = entropy < 0.5 && maxConfidence > 0.98;

    String predictedLabel;
    bool isConfident;
    bool isLikelyCrop;

    // Main Logic: A single, clear `if` statement for rejection
    if (hasUnrealisticConfidence ||
        hasConfusion ||
        hasFlatDistribution ||
        isSuspiciouslyConfident) {
      predictedLabel = "Not a crop";
      isLikelyCrop = false;
      isConfident = false;
    }
    // Strict Crop Detection: Only proceed if confidence and distribution are good
    else if (maxConfidence >= 0.75 &&
        maxConfidence <= 0.95 &&
        entropy >= 1.0 &&
        entropy <= 3.5) {
      predictedLabel = predictedIndex >= 0 &&
              _labels != null &&
              predictedIndex < _labels!.length
          ? _labels![predictedIndex]
          : "Unknown";
      isLikelyCrop = true;
      isConfident = maxConfidence >= 0.85;
    }
    // Low Confidence / Uncertain: For predictions that don't meet the strict criteria
    else {
      predictedLabel = "Uncertain detection";
      isLikelyCrop = false;
      isConfident = false;
    }

    return {
      'label': predictedLabel,
      'confidence': maxConfidence,
      'isConfident': isConfident,
      'isLikelyCrop': isLikelyCrop,
      'entropy': entropy,
      'debugInfo': {
        'hasUnrealisticConfidence': hasUnrealisticConfidence,
        'hasConfusion': hasConfusion,
        'hasFlatDistribution': hasFlatDistribution,
        'isSuspiciouslyConfident': isSuspiciouslyConfident,
      },
      'allProbabilities': Map.fromIterables(
        _labels ?? List.generate(_outputLength, (i) => 'Class_$i'),
        probabilities,
      ),
    };
  }

  // Helper function to check if the probability distribution is "reasonable".
  bool _hasReasonableDistribution(List<double> probabilities) {
    List<double> sortedProbs = List.from(probabilities)
      ..sort((a, b) => b.compareTo(a));
    if (sortedProbs.isEmpty) return false;
    final double maxProb = sortedProbs[0];
    final double secondMaxProb = sortedProbs.length > 1 ? sortedProbs[1] : 0.0;
    if (maxProb < 0.6 || maxProb > 0.98) return false;
    if (secondMaxProb > maxProb * 0.8) return false;
    int significantPredictions = probabilities.where((p) => p > 0.1).length;
    if (significantPredictions > 4) return false;
    return true;
  }

  // Helper function to check for "confused" predictions.
  bool _hasConfusedPrediction(List<double> probabilities) {
    List<double> sortedProbs = List.from(probabilities)
      ..sort((a, b) => b.compareTo(a));
    if (sortedProbs.length < 2) return false;
    int closeValues = 0;
    for (int i = 0; i < sortedProbs.length - 1; i++) {
      if (sortedProbs[i] > 0.3 &&
          (sortedProbs[i] - sortedProbs[i + 1]).abs() < 0.2) {
        closeValues++;
      }
    }
    return closeValues >= 2;
  }

  String _sanitizeError(dynamic error) {
    final errorStr = error.toString();
    final parts = errorStr.split(':');
    return parts.length > 1 ? parts.last.trim() : errorStr;
  }

  Future<void> _cleanup() async {
    _isolateInterpreter?.close();
    _isolateInterpreter = null;
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }

  @override
  void dispose() {
    _cleanup();
    _setStatus(ModelPredictionStatus.initial);
    log("TFLiteModelServices: Resources disposed");
    super.dispose();
  }
}
