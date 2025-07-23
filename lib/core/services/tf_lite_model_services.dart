import 'dart:developer';
import 'dart:io';
import 'package:flutter/widgets.dart';
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

class TfLiteModelServices extends ChangeNotifier {
  Interpreter? _interpreter;
  List<String>? _labels;
  ModelPredictionStatus _status = ModelPredictionStatus.initial;

  static const String _modelPath = "assets/ml_models/converted_model.tflite";
  static const String _labelPath = "assets/ml_models/labels.txt";
  static const int _inputSize = 256;
  static const int _channels = 3;
  static const int _outputLength = 16;

  Interpreter? get interpreter => _interpreter;
  List<String>? get labels => _labels;
  ModelPredictionStatus get status => _status;

//private setter for status with notification
  void _setStatus(ModelPredictionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
      log("TFLiteModelServices: Status changed to $_status");
    }
  }

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
      throw Exception(
          "Model not ready for prediction. Call loadModelAndLabels first.");
    }

    _setStatus(ModelPredictionStatus.predicting);
    try {
      //read image bytes
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception("Failed to decode image ");
      }
      img.Image resizedImage =
          img.copyResize(originalImage, width: _inputSize, height: _inputSize);

      // Convert image to a 4D list of doubles (normalized pixel values 0-1)
      // Expected input format for TFLite is typically [1, height, width, channels] for images.

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

      //tensorflow lite mdoels expect a batch dimension [1, height, width, channels]
      var inputTensor = [imageInput];

      //output buffer which will be a list of probabilities for each class
      var outputBuffer =
          List.filled(_outputLength, 0.0).reshape([1, _outputLength]);

      //I run inference on a seperate isolate to create a new IsolateInterpretor for each predicton if needed,
      //I create it for each run here. For high freequency, consider sung a single IsolateInterpreter from laodModelAndLabels.
      // Let's adjust to create IsolateInterpreter once with the interpreter.
      final isolateInterpreter =
          await IsolateInterpreter.create(address: _interpreter!.address);
      await isolateInterpreter.run(inputTensor, outputBuffer);
      isolateInterpreter.close();

      //post-proces output
      //index with highest probability
      List<double> probabilities = List<double>.from(outputBuffer[0]);
      double maxConfidence = 0.0;
      int predictedIndex = -1;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          predictedIndex = i;
        }
      }
      String predictedLabel = (predictedIndex != -1 &&
              _labels != null &&
              predictedIndex < _labels!.length)
          ? _labels![predictedIndex]
          : "Unknown";

      log("TFLiteModelService: Prediction complete. Label : $predictedLabel, confidence: ${maxConfidence.toStringAsFixed(2)}");
      return {
        'label': predictedLabel,
        'confidence': maxConfidence,
      };
    } catch (e) {
      _setStatus(ModelPredictionStatus.error);
      log('TFLiteModelServiCe: Error during prediction: $e', error: e);
      throw Exception("Prediction failed: ${e.toString()}");
    } finally {
      //resetting status after prediction or keep predicting if continuous
      if (_status != ModelPredictionStatus.error) {
        _status = ModelPredictionStatus.ready;
      }
    }
  }

  @override
  void dispose() {
    _interpreter?.close(); // Close the interpreter to free resources
    _interpreter = null;
    _labels = null;
    _setStatus(ModelPredictionStatus.initial); // Reset status to initial
    log("TFLiteModelService: Interpreter and resources disposed.");
    super.dispose(); // Call super.dispose()
  }
}
    // Intellectual Opponent: Your current strategy for IsolateInterpreter.create
      // inside `predictedImage` means a new isolate is created and torn down for *each* prediction.
      // While it guarantees isolation, for high frequency predictions, the overhead
      // of creating and tearing down isolates can impact performance.
      // A common optimization for continuous or frequent prediction is to
      // create and maintain a single `IsolateInterpreter` for the lifecycle of your
      // `TfLiteModelServices` class, possibly within `loadModelAndLabels`,
      // and then just use `isolateInterpreter.run` for subsequent predictions.
      //
      // For a final year project with occasional predictions, your current approach is fine
      // and safer against resource leaks if not disposed properly.
      // For production-grade high-throughput, reconsider this.
