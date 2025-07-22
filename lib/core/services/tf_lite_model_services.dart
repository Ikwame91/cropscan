import 'dart:developer';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelPredictionStatus {
  loading,
  ready,
  predicting,
  error,
  initial,
}

class TfLiteModelServices {
  Interpreter? _interpreter;
  List<String>? _labels;
  ModelPredictionStatus _status = ModelPredictionStatus.initial;

  static const String _modelPath = "assets/ml_models/converted_model.tflite";
  static const String _labelPath = "assets/ml_models/labels.txt";
  static const int _inputSize = 224;
  static const int _channels = 3;
  static const int _outputLength = 16;

  Interpreter? get interpreter => _interpreter;
  List<String>? get labels => _labels;
//called once typically at startup or when the model is needed
  Future<void> loadModelAndLabels() async {
    if (_status == ModelPredictionStatus.loading ||
        _status == ModelPredictionStatus.ready) {
      log("Model and labels already loaded or loading .");
    }

    _status = ModelPredictionStatus.loading;
    log("TfliteModelServices: Loading model and labels...");
    try {
      //load the model
      //we use the IsolateInterpreter directly for asynchronous inference
      _interpreter = await Interpreter.fromAsset(_modelPath);
      log("TfliteModelServices: Model loaded successfully.");

      //load the labels
      final labelsData = await rootBundle.loadString(_labelPath);
      _labels = labelsData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
      log('TFliteModelServices: Labels loaded successfully. Count: ${_labels?.length}');

      //basic validation
      if (_interpreter!.getInputTensors().isEmpty ||
          _interpreter!.getOutputTensors().isEmpty) {
        throw Exception("Model has no input or output tensors. Check validity");
      }
      final inputShape = _interpreter!.getInputTensors()[0].shape;
      final outputShape = _interpreter!.getOutputTensors()[0].shape;

      log("TFliteModelServices: Input shape: $inputShape, Output shape: $outputShape");

      //validate input shape matches expected dimensions
      if (inputShape.length != 4 ||
          inputShape[1] != _inputSize ||
          inputShape[2] != _inputSize ||
          inputShape[3] != _channels) {
        throw Exception(
            "WARNING: model input shape {$inputShape} does not match expected dimensions [ $_inputSize, $_inputSize, $_channels]");
      }

      if (outputShape.length != 2 || outputShape[1] != _outputLength) {
        throw Exception(
            "WARNING: model output shape {$outputShape} does not match expected dimensions [ $_outputLength]");
      }
      if (_labels?.length != _outputLength) {
        log("WARNING: Number of labels ${_labels?.length} does not match model output length $_outputLength");
      }
      _status = ModelPredictionStatus.ready;
      log("TFLiteModelServices: Model service is ready");
    } catch (e) {
      _status = ModelPredictionStatus.error;
      _interpreter?.close();
      _interpreter = null;
      log("TFLiteModelServices: Error loading model or labels: $e", error: e);
      rethrow;
    }
  }

  //runs inference on the provided image file
  //returns a map containg the predicted label and confidence
  Future<Map<String, dynamic>?> predictedImage(File imageFile) async {
    if (_status != ModelPredictionStatus.ready ||
        _interpreter == null ||
        _labels == null) {
      log("TFLiteModelServices: Model is not ready or labels are not loaded.");
      return null;
    }
    try {
      //read image bytes
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception("Failed to decode image ");
      }
      img.Image resizedImage =
          img.copyResize(originalImage, width: _inputSize, height: _inputSize);
      //convert image to a list of doubles(normalized pixel valeue 0-1)
      //if model expects float32input with values between 0.0 and 1.0
      //if model expects uint8 input (0-255) , adjust normalization
      var imageInput = List.generate(_inputSize, (y) {
        return List.generate(_inputSize, (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            (pixel.r / 255.0),
            (pixel.g / 255.0),
            (pixel.b / 255.0),
          ];
        });
      });
    } catch (e) {}
  }
}
