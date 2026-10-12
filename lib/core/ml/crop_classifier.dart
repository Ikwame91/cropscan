import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cropscan_pro/core/ml/classification_result.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelPredictionStatus { initial, loading, ready, predicting, error }

/// Loads the on-device TFLite model and classifies leaf photos.
class CropClassifier extends ChangeNotifier {
  static const String modelPath = 'assets/ml_models/converted_model.tflite';
  static const String labelPath = 'assets/ml_models/labels.txt';
  static const int inputSize = 256;
  static const int channels = 3;

  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  List<String> _labels = const [];
  String? _errorMessage;
  ModelPredictionStatus _status = ModelPredictionStatus.initial;

  List<String> get labels => _labels;
  String? get errorMessage => _errorMessage;
  ModelPredictionStatus get status => _status;
  bool get isReady => _status == ModelPredictionStatus.ready;

  void _setStatus(ModelPredictionStatus newStatus, {String? message}) {
    if (_status == newStatus && _errorMessage == message) return;
    _status = newStatus;
    _errorMessage = message;
    notifyListeners();
    log('CropClassifier: $_status${message != null ? ' - $message' : ''}');
  }

  Future<void> loadModelAndLabels() async {
    if (_status == ModelPredictionStatus.loading || isReady) return;
    _setStatus(ModelPredictionStatus.loading);

    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      _isolateInterpreter =
          await IsolateInterpreter.create(address: _interpreter!.address);
      _labels = parseLabels(await rootBundle.loadString(labelPath));
      _validateModel();
      _setStatus(ModelPredictionStatus.ready);
    } catch (e) {
      await _cleanup();
      _setStatus(ModelPredictionStatus.error,
          message: 'Initialization failed: $e');
      rethrow;
    }
  }

  static List<String> parseLabels(String raw) => raw
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList(growable: false);

  void _validateModel() {
    final inputShape = _interpreter!.getInputTensors().first.shape;
    final outputShape = _interpreter!.getOutputTensors().first.shape;

    if (inputShape.length != 4 ||
        inputShape[1] != inputSize ||
        inputShape[2] != inputSize ||
        inputShape[3] != channels) {
      throw StateError('Unexpected model input shape $inputShape');
    }
    if (outputShape.length != 2 || outputShape[1] != _labels.length) {
      throw StateError(
        'Model has ${outputShape.last} outputs but labels.txt has '
        '${_labels.length} labels',
      );
    }
  }

  Future<ClassificationResult> classify(File imageFile) async {
    if (!isReady || _isolateInterpreter == null) {
      throw StateError('Model not ready. Call loadModelAndLabels() first');
    }
    _setStatus(ModelPredictionStatus.predicting);

    try {
      final path = imageFile.path;
      // Decoding and resizing a full-size photo takes hundreds of ms, so keep
      // it off the UI isolate.
      final input = await Isolate.run(() => preprocessFile(path));
      final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
      await _isolateInterpreter!.run(
        input.reshape([1, inputSize, inputSize, channels]),
        output,
      );

      final result = ClassificationResult.fromProbabilities(
        List<double>.from(output[0] as List),
        _labels,
      );
      log('CropClassifier: ${result.top} → ${result.outcome.name}');
      _setStatus(ModelPredictionStatus.ready);
      return result;
    } catch (e) {
      // A single failed image shouldn't take the model offline.
      _setStatus(ModelPredictionStatus.ready);
      log('CropClassifier: prediction failed - $e');
      rethrow;
    }
  }

  static Float32List preprocessFile(String path) {
    final bytes = File(path).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Unsupported or corrupted image file');
    }
    return preprocess(img.bakeOrientation(decoded));
  }

  /// Converts an image into the model's flat input tensor.
  ///
  /// Pixel values are deliberately left in the 0–255 range: the model's
  /// `Rescaling(1/255)` layer was folded into the first convolution's weights
  /// when it was converted to TFLite. Feeding 0–1 values makes it predict the
  /// same class for every image.
  static Float32List preprocess(img.Image image) {
    var source = image;
    if (source.format != img.Format.uint8) {
      // e.g. 16-bit PNGs, whose channels would otherwise range to 65535.
      source = source.convert(format: img.Format.uint8);
    }
    if (source.hasAlpha) {
      final background = img.Image(width: source.width, height: source.height)
        ..clear(img.ColorRgb8(255, 255, 255));
      source = img.compositeImage(background, source);
    }

    final resized = img.copyResize(
      source,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    final data = Float32List(inputSize * inputSize * channels);
    var i = 0;
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        data[i++] = pixel.r.toDouble();
        data[i++] = pixel.g.toDouble();
        data[i++] = pixel.b.toDouble();
      }
    }
    return data;
  }

  Future<void> _cleanup() async {
    _isolateInterpreter?.close();
    _isolateInterpreter = null;
    _interpreter?.close();
    _interpreter = null;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
