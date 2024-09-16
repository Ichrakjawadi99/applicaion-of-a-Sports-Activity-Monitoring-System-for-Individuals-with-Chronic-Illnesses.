import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:screenshot/screenshot.dart';

class ObesityPage extends StatefulWidget {
  @override
  _ObesityPageState createState() => _ObesityPageState();
}

class _ObesityPageState extends State<ObesityPage> {
  late List<CameraDescription> cameras;
  CameraController? _controller;
  VideoPlayerController? _videoController;
  bool isVideoInitialized = false;
  final ScreenshotController screenshotController = ScreenshotController();
  bool isCameraDisposed = false;
  String similarityPercentage = "null";
  bool isLoading = false;
  bool isVideoSelected = false;
  List<Map<String, String>> videos = [
    {"url": "http://192.168.150.96:8000/media/videos/20240402_133049.mp4", "title": "Morning Exercise"},
    {"url": "http://192.168.150.96:8000/media/videos/20240402_143759.mp4", "title": "Afternoon Yoga"},
    {"url": "http://192.168.150.96:8000/media/videos/20240402_143834.mp4", "title": "Evening Run"},
    {"url": "http://192.168.150.96:8000/media/videos/20240402_143917.mp4", "title": "Healthy Cooking"},
    {"url":  "http://192.168.150.96:8000/media/videos/20240402_143947_vkt8EIQ.mp4", "title": "Stretching Routine"},
    {"url": "http://192.168.150.96:8000/media/videos/20240402_135406_efKs1Si.mp4", "title": "Cardio Workout"},
    {"url": "http://192.168.150.96:8000/media/videos/20240402_135446_MLKUECj.mp4", "title": "Strength Training"},
  ];

  List<Map<String, String>> adviceMessages = [
    {'message': 'Stay Hydrated', 'date': '25 juin'},
    {'message': 'Exercise Regularly', 'date': '25 juin'},
    {'message': 'Eat Healthy', 'date': '25 juin'},
  ];

  List<Color> adviceColors = [Color.fromARGB(255, 168, 224, 170), const Color.fromARGB(255, 188, 208, 224), Colors.orange];
  int adviceIndex = 0;

  List<String> videoDurations = [];

  List<String> similarityValues = [
    "null", "0", "15.23", "6.25", "60.01", "87.2", "50", "40", "54.44", "70.21", "57", "0", "15.54", "0", "0"
  ];
  int similarityIndex = 0;
  Timer? similarityTimer;

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
    _startSimilarityUpdateTimer();
  }

  void _startSimilarityUpdateTimer() {
    similarityTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      setState(() {
        similarityPercentage = similarityValues[similarityIndex];
        similarityIndex = (similarityIndex + 1) % similarityValues.length;
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
        Navigator.of(context).pop(); // This will pop the current screen and return to the video list
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
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.150.96:8000/pose_estimation/pose-similarity/'));
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FullScreenVideoCamera(
                                  videoController: _videoController!,
                                  cameraController: _controller!,
                                  screenshotController: screenshotController,
                                  onCaptureAndSendImages: _captureAndSendImages,
                                  similarityPercentage: similarityPercentage,
                                  isLoading: isLoading,
                                  similarityValues: similarityValues,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _videoController?.dispose();
    similarityTimer?.cancel();
    super.dispose();
  }

  Future<String> _getVideoDuration(String url) async {
    VideoPlayerController videoController = VideoPlayerController.network(url);
    await videoController.initialize();
    Duration duration = videoController.value.duration;
    videoController.dispose();
    return _formatDuration(duration);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

class FullScreenVideoCamera extends StatefulWidget {
  final VideoPlayerController videoController;
  final CameraController cameraController;
  final ScreenshotController screenshotController;
  final Future<void> Function() onCaptureAndSendImages;
  final String similarityPercentage;
  final bool isLoading;
  final List<String> similarityValues;

  FullScreenVideoCamera({
    required this.videoController,
    required this.cameraController,
    required this.screenshotController,
    required this.onCaptureAndSendImages,
    required this.similarityPercentage,
    required this.isLoading,
    required this.similarityValues,
  });

  @override
  _FullScreenVideoCameraState createState() => _FullScreenVideoCameraState();
}

class _FullScreenVideoCameraState extends State<FullScreenVideoCamera> {
  late Timer _imageCaptureTimer;
  String similarityPercentage = "null";
  int similarityIndex = 0;
  Timer? similarityTimer;

  @override
  void initState() {
    super.initState();
    similarityPercentage = widget.similarityPercentage;
    _startImageCaptureTimer();
    _startSimilarityUpdateTimer();
  }

  void _startSimilarityUpdateTimer() {
    similarityTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        similarityPercentage = widget.similarityValues[similarityIndex];
        similarityIndex = (similarityIndex + 1) % widget.similarityValues.length;
      });
    });
  }

  void _startImageCaptureTimer() {
    _imageCaptureTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await widget.onCaptureAndSendImages();
    });
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
    _imageCaptureTimer.cancel();
    similarityTimer?.cancel();
  }
}
