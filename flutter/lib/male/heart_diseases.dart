import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:screenshot/screenshot.dart';

class HeartDiseasesPage extends StatefulWidget {
  @override
  _HeartDiseasesPageState createState() => _HeartDiseasesPageState();
}

class _HeartDiseasesPageState extends State<HeartDiseasesPage> {
  late List<CameraDescription> cameras;
  CameraController? _controller;
  VideoPlayerController? _videoController;
  bool isVideoInitialized = false;
  final ScreenshotController screenshotController = ScreenshotController();
  bool isCameraDisposed = false;
  String similarityPercentage = "0";
  bool isLoading = false;
  bool isVideoSelected = false;
  List<Map<String, String>> videos = [
 {"url": "http://192.168.162.96:8000/media/videos/hw.mp4", "title": "Morning Exercise"},
    {"url": "http://192.168.162.96:8000/media/videos/o.mp4" "Afternoon Yoga"},
    {"url": "http://192.168.162.96:8000/media/videos/h.mp4", "title": "Evening Run"},
    {"url": "http://192.168.162.96:8000/media/videos/h_LZTxJJV.mp4", "title": "Healthy Cooking"},
    {"url":  "http://192.168.162.96:8000/media/videos/h..mp4", "title": "Stretching Routine"},
    {"url":  "http://192.168.162.96:8000/media/videos/hf.mp4", "title": "Cardio Workout"},
    {"url": "http://192.168.162.96:8000/media/videos/hi.mp4", "title": "Strength Training"},
  ];

   List<Map<String, String>> adviceMessages = [
    {'message': 'Stay Hydrated', 'date': '25 juin'},
    {'message': 'Exercise Regularly', 'date': '25 juin'},
    {'message': 'Eat Healthy', 'date': '25 juin'},
  ];

  List<Color> adviceColors = [Colors.green, Colors.blue, Colors.orange];
  int adviceIndex = 0;

  List<String> videoDurations = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera().catchError((error) {
      _showSnackBar("Error initializing camera: $error");
    });
    _initializeVideoDurations();
    Timer.periodic(Duration(seconds: 7), (Timer timer) {
      setState(() {
        adviceIndex = (adviceIndex + 1) % adviceMessages.length;
      });
    });
  }

  Future<void> _initializeVideoDurations() async {
    for (var video in videos) {
      String duration = await _getVideoDuration(video["url"]!);
      videoDurations.add(duration);
    }
    setState(() {});
  }

  Future<void> _initializeVideoPlayer(String url) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(url);
    await _videoController?.initialize();
    setState(() {
      isVideoInitialized = true;
    });
    _videoController?.play();
    _videoController?.addListener(() {
      if (_videoController!.value.position == _videoController!.value.duration) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
    } catch (error) {
      _showSnackBar("Error initializing camera: $error");
    }
  }

  Future<void> _initializeCameraController() async {
    try {
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller = CameraController(frontCamera, ResolutionPreset.medium);
      await _controller?.initialize();
      setState(() {});
    } catch (error) {
      _showSnackBar("Error initializing camera: $error");
    }
  }

  Future<void> _captureAndSendImages() async {
    if (_controller != null && _videoController != null && !isCameraDisposed) {
      setState(() {
        isLoading = true;
      });

      try {
        XFile cameraImage = await _controller!.takePicture();
        Uint8List? videoFrame = await screenshotController.capture();

        if (videoFrame != null) {
          print('Camera Image Path: ${cameraImage.path}');
          print('Captured Video Frame Length: ${videoFrame.length}');
          await _sendImagesToBackend(cameraImage, videoFrame);
        } else {
          _showSnackBar("Failed to capture video frame.");
        }
      } catch (e) {
        _showSnackBar('Error capturing and sending images: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _sendImagesToBackend(XFile cameraImage, Uint8List? videoFrame) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.26.96:8000/pose_estimation/pose-similarity/'));
    request.files.add(http.MultipartFile('image1', cameraImage.readAsBytes().asStream(), await cameraImage.length(), filename: 'camera_image.jpg'));
    request.files.add(http.MultipartFile('image2', http.ByteStream.fromBytes(videoFrame!), videoFrame.length, filename: 'video_frame.jpg'));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        if (jsonResponse['similarity_percentage'] != null) {
          setState(() {
            similarityPercentage = jsonResponse['similarity_percentage'].toString();
          });
        } else {
          _showSnackBar('Invalid response from server.');
        }
      } else {
        _showSnackBar('Error sending images: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Failed to send images: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vidéo du jour'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Advice Container
          Container(
            height: 150,
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: adviceColors[adviceIndex],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    adviceMessages[adviceIndex]['message']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      adviceMessages[adviceIndex]['date']!,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isVideoSelected
                ? Container()
                : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return Container(
                  height: 80,
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(videos[index]["title"]!),
                    subtitle: Text("Duration: ${videoDurations.isNotEmpty ? videoDurations[index] : 'Loading...'}"),
                    onTap: () async {
                      setState(() {
                        isVideoSelected = false;
                      });
                      await _initializeCameraController();
                      _initializeVideoPlayer(videos[index]["url"]!);
                      setState(() {
                        isVideoSelected = true;
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FullScreenVideoCamera(
                          videoController: _videoController!,
                          cameraController: _controller!,
                          screenshotController: screenshotController,
                          onCaptureAndSendImages: _captureAndSendImages,
                          similarityPercentage: similarityPercentage,
                          isLoading: isLoading,
                        ),
                      ));
                    },
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<String> _getVideoDuration(String url) async {
    final controller = VideoPlayerController.network(url);
    await controller.initialize();
    final duration = controller.value.duration;
    controller.dispose();
    return duration.toString().split('.').first;
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
    _controller?.dispose();
    isCameraDisposed = true;
  }
}

class FullScreenVideoCamera extends StatefulWidget {
  final VideoPlayerController videoController;
  final CameraController cameraController;
  final ScreenshotController screenshotController;
  final Future<void> Function() onCaptureAndSendImages;
  final String similarityPercentage;
  final bool isLoading;

  FullScreenVideoCamera({
    required this.videoController,
    required this.cameraController,
    required this.screenshotController,
    required this.onCaptureAndSendImages,
    required this.similarityPercentage,
    required this.isLoading,
  });

  @override
  _FullScreenVideoCameraState createState() => _FullScreenVideoCameraState();
}

class _FullScreenVideoCameraState extends State<FullScreenVideoCamera> {
  late Timer _similarityUpdateTimer;
  late Timer _imageCaptureTimer;
  String similarityPercentage = "0";

  @override
  void initState() {
    super.initState();
    similarityPercentage = widget.similarityPercentage;
    _startSimilarityUpdateTimer();
    _startImageCaptureTimer();
  }

  void _startSimilarityUpdateTimer() {
    _similarityUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      String newSimilarityPercentage = await _fetchSimilarityPercentage();
      setState(() {
        similarityPercentage = newSimilarityPercentage;
      });
    });
  }

  void _startImageCaptureTimer() {
    _imageCaptureTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await widget.onCaptureAndSendImages();
    });
  }

  Future<String> _fetchSimilarityPercentage() async {
    final response = await http.get(Uri.parse('http://192.168.26.96:8000/pose_estimation/pose-similarity/'));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse['similarity_percentage'].toString();
    } else {
      return "0";
    }
  }

  Color _getSimilarityColor() {
    double percentage = double.tryParse(similarityPercentage) ?? 0;
    if (percentage > 50) {
      return Colors.green;
    } else if (percentage < 50) {
      return Colors.red;
    } else {
      return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Screenshot(
                  controller: widget.screenshotController,
                  child: VideoPlayer(widget.videoController),
                ),
              ),
              Container(
                height: 50,
                width: double.infinity,
                color: _getSimilarityColor(),
                child: Center(
                  child: Text(
                    'Similarity: $similarityPercentage%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CameraPreview(widget.cameraController),
              ),
            ],
          ),
          if (widget.isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onCaptureAndSendImages,
        child: Icon(Icons.camera),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _similarityUpdateTimer.cancel();
    _imageCaptureTimer.cancel();
  }
}

void main() {
  runApp(MaterialApp(
    home: HeartDiseasesPage(),
  ));
}
