import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';

Future<List<dynamic>> fetchDataFromDjango() async {
  final String apiUrl = 'http://192.168.162.96:8000/api/healthdata/';  // Corrigez l'URL ici
  final Uri apiUri = Uri.parse(apiUrl);

  final response = await http.get(apiUri);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load data from API');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OxygenPage(),
      theme: ThemeData.dark(),
    );
  }
}

class OxygenPage extends StatefulWidget {
  @override
  _OxygenPageState createState() => _OxygenPageState();
}

class _OxygenPageState extends State<OxygenPage> {
  List<dynamic>? sensorData;
  Timer? _timer;
  PageController _pageController = PageController();
  List<int> spo2Values = [0, 69, 90, 98 , 100, 90, 72, 70, 75, 72];
  List<int> irValues = [0, 70, 75, 72, 79, 80, 78 , 70, 75, 72];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer t) => updateData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final data = await fetchDataFromDjango();
      setState(() {
        sensorData = data;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void updateData() {
    setState(() {
      currentIndex = (currentIndex + 1) % spo2Values.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Measurement Carousel'),
        backgroundColor: Colors.green,
      ),
      body: PageView(
        controller: _pageController,
        children: [
          HeartRatePage(sensorData: sensorData, bpm: irValues[currentIndex]),
          OxygenPageIndicator(sensorData: sensorData, spo2: spo2Values[currentIndex]),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}

class HeartRatePage extends StatelessWidget {
  final List<dynamic>? sensorData;
  final int bpm;

  HeartRatePage({this.sensorData, required this.bpm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 10.0,
            percent: bpm / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 30),
                Text(
                  '$bpm BPM',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            progressColor: Colors.red,
            backgroundColor: Colors.grey[800] ?? Colors.grey,
          ),
          SizedBox(height: 20),
          CustomPaint(
            size: Size(double.infinity, 100),
            painter: HeartRateCurvePainter(),
          ),
        ],
      ),
    );
  }
}

class OxygenPageIndicator extends StatelessWidget {
  final List<dynamic>? sensorData;
  final int spo2;

  OxygenPageIndicator({this.sensorData, required this.spo2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 10.0,
            percent: spo2 / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.air, color: Colors.blue, size: 30),
                Text(
                  '$spo2 %SpO2',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            progressColor: Colors.blue,
            backgroundColor: Colors.grey[800] ?? Colors.grey,
          ),
          SizedBox(height: 20),
          CustomPaint(
            size: Size(double.infinity, 100),
            painter: OxygenCurvePainter(),
          ),
        ],
      ),
    );
  }
}

class HeartRateCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Create a heart rate curve
    path.moveTo(0, size.height / 2);
    for (int i = 0; i < size.width; i += 10) {
      path.lineTo(i.toDouble(), (i % 20 == 0) ? size.height / 4 : size.height / 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class OxygenCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Create an oxygen saturation curve
    path.moveTo(0, size.height / 2);
    path.cubicTo(size.width / 4, size.height * 3 / 4, size.width * 3 / 4, size.height / 4, size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
