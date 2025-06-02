import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class YogaPoseClassifier extends StatefulWidget {
  final String poseName;

  const YogaPoseClassifier({Key? key, required this.poseName}) : super(key: key);

  @override
  _YogaPoseClassifierState createState() => _YogaPoseClassifierState();
}

class _YogaPoseClassifierState extends State<YogaPoseClassifier> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _feedback = "Press 'Start Camera' to begin";
  Uint8List? _processedImage;
  bool _isProcessing = false;
  final FlutterTts _flutterTts = FlutterTts();
  bool _showSkeleton = false;
  bool _cameraStarted = false;
  bool _isFrontCamera = false;
  List<CameraDescription> _cameras = [];
  Timer? _countdownTimer;
  int _secondsRemaining = 10;

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error accessing cameras: $e");
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) {
      Fluttertoast.showToast(msg: "No available cameras found");
      return;
    }

    _controller = CameraController(
      _isFrontCamera
          ? _cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front)
          : _cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.back),
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() => _cameraStarted = true);

    await _initializeControllerFuture;
    _startPoseCountdown();
  }

  void _startPoseCountdown() {
    setState(() {
      _secondsRemaining = 10;
    });

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          _processFrame();
        }
      });
    });
  }

  Future<void> _processFrame() async {
    if (_isProcessing || _controller == null || !_controller!.value.isInitialized) return;
    setState(() => _isProcessing = true);

    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();

      var url = Uri.parse('http://192.168.186.247:8000/classify-pose/');
      var request = http.MultipartRequest('POST', url)
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'frame.jpg'))
        ..fields['selected_pose'] = widget.poseName;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        setState(() {
          _feedback = jsonResponse['incorrect_parts'].isEmpty
              ? "Perfect!"
              : "Incorrect parts: ${jsonResponse['incorrect_parts'].join(', ')}. Adjust your pose.";
          _processedImage = base64Decode(jsonResponse['skeleton_image']);
          _showSkeleton = true;
        });
        await _flutterTts.speak(_feedback);
      } else {
        Fluttertoast.showToast(msg: "Error: ${jsonResponse['error']}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Processing failed: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _switchCamera() async {
    setState(() => _isFrontCamera = !_isFrontCamera);
    await _initializeCamera();
  }

  void _retryPose() {
    setState(() {
      _feedback = "Get ready for the next attempt!";
      _processedImage = null;
      _showSkeleton = false;
      _isProcessing = false;
      _secondsRemaining = 10;
    });
    _startPoseCountdown();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _flutterTts.stop();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poseName),
        actions: [
          if (_cameraStarted)
            IconButton(
              icon: Icon(Icons.switch_camera),
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: _cameraStarted
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return CameraPreview(_controller!);
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                      if (_showSkeleton && _processedImage != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.7,
                            child: Image.memory(_processedImage!),
                          ),
                        ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _secondsRemaining > 0 ? "Get ready... $_secondsRemaining s" : _feedback,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Retry Button - Only visible after processing is complete
                if (!_isProcessing && _secondsRemaining == 0)
                  ElevatedButton(
                    onPressed: _retryPose,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text("Retry Pose"),
                  ),
                SizedBox(height: 10),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "“Yoga is the journey of the self, through the self, to the self.”",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lobster(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _initializeCamera,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text("Start Camera"),
                  ),
                ],
              ),
            ),
    );
  }
}
