import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class YogaPoseClassifier extends StatefulWidget {
  final String poseName;

  YogaPoseClassifier({required this.poseName});

  @override
  _YogaPoseClassifierState createState() => _YogaPoseClassifierState();
}

class _YogaPoseClassifierState extends State<YogaPoseClassifier> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String _feedback = "No feedback yet.";
  String _predictedPose = "Unknown";
  bool _isCorrect = false;
  List<String> _incorrectParts = [];
  Map<String, dynamic> _angles = {};
  Uint8List? _skeletonImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller.initialize();
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // Convert the camera frame to a JPEG image
      final bytes = await _convertImageToBytes(image);
      if (bytes == null) return;

      // Send the image to the API
      var url = Uri.parse('http://127.0.0.1:5000/classify-pose/');
      var request = http.MultipartRequest('POST', url);

      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'frame.jpg'));
      request.fields['selected_pose'] = widget.poseName;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        setState(() {
          _predictedPose = jsonResponse['predicted_pose'];
          _isCorrect = jsonResponse['is_correct'];
          _incorrectParts = List<String>.from(jsonResponse['incorrect_parts']);
          _angles = Map<String, dynamic>.from(jsonResponse['angles']);
          _feedback = _isCorrect
              ? "Perfect!"
              : "Incorrect parts: ${_incorrectParts.join(', ')}. Please correct your pose.";
          _skeletonImage = base64Decode(jsonResponse['skeleton_image']);
        });
      } else {
        Fluttertoast.showToast(msg: "Error: ${jsonResponse['error']}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Processing failed: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<Uint8List?> _convertImageToBytes(CameraImage image) async {
    try {
      final planes = image.planes;
      final byteData = planes[0].bytes;
      final buffer = byteData.buffer;
      return Uint8List.view(buffer);
    } catch (e) {
      print("Error converting image to bytes: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.poseName)),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_controller);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              _skeletonImage != null
                  ? Image.memory(_skeletonImage!)
                  : Container(),
              SizedBox(height: 20),
              Text("Predicted Pose: $_predictedPose", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text("Match Result: ${_isCorrect ? 'Correct' : 'Incorrect'}", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text("Angles: ${_angles.toString()}", textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
              SizedBox(height: 10),
              Text(_feedback, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _controller.startImageStream((image) => _processFrame(image));
                },
                child: Text('Start Real-Time Classification'),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}