import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

void main() {
  runApp(ExoplanetTrackerApp());
}

class ExoplanetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exoplanet Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: ExoplanetTrackerHome(),
    );
  }
}

class ExoplanetTrackerHome extends StatefulWidget {
  @override
  _ExoplanetTrackerHomeState createState() => _ExoplanetTrackerHomeState();
}

class _ExoplanetTrackerHomeState extends State<ExoplanetTrackerHome> {
  Map<String, dynamic>? exoplanetData;
  final String apiEndpoint = 'http://localhost:5000/exoplanet_positions';
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchExoplanetData();
  }

  Future<void> fetchExoplanetData() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_currentDate);
    try {
      final response = await http.get(Uri.parse('$apiEndpoint?date=$dateStr'));
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          exoplanetData = json.decode(response.body);
        });
        print('Decoded Exoplanet Data: $exoplanetData');
      } else {
        throw Exception('Failed to load exoplanet data');
      }
    } catch (e) {
      print('Error fetching exoplanet data: $e');
      setState(() {
        exoplanetData = {'error': 'Failed to fetch data'};
      });
    }
  }

  void _changeDate(int days) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
    });
    fetchExoplanetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exoplanet Tracker'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(_currentDate)}',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Expanded(
            child: exoplanetData == null
                ? Center(child: CircularProgressIndicator())
                : ExoplanetDisplay(exoplanetData: exoplanetData!),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _changeDate(-1),
                  child: Icon(Icons.arrow_back),
                ),
                ElevatedButton(
                  onPressed: () => _changeDate(1),
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExoplanetDisplay extends StatelessWidget {
  final Map<String, dynamic> exoplanetData;

  ExoplanetDisplay({required this.exoplanetData});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ExoplanetPainter(exoplanetData: exoplanetData),
      child: Container(),
    );
  }
}

class ExoplanetPainter extends CustomPainter {
  final Map<String, dynamic> exoplanetData;

  ExoplanetPainter({required this.exoplanetData});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        size.width < size.height ? size.width / 2 : size.height / 2;

    // Draw the star
    final starPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(center, maxRadius * 0.05, starPaint);

    // Debug: Print exoplanet data
    print('Exoplanet Data: $exoplanetData');

    // Check if exoplanetData contains the 'exoplanets' key
    if (exoplanetData.containsKey('exoplanets') &&
        exoplanetData['exoplanets'] is Map<String, dynamic>) {
      exoplanetData['exoplanets'].forEach((name, data) {
        if (data is Map<String, dynamic> &&
            data.containsKey('r') &&
            data.containsKey('theta')) {
          // Scale the distance (r) to fit within the canvas
          final r =
              (data['r'] as double) * maxRadius * 0.9; // Use 90% of maxRadius
          final theta = (data['theta'] as double);

          final x = center.dx + r * math.cos(theta * math.pi / 180);
          final y = center.dy + r * math.sin(theta * math.pi / 180);

          // Draw orbit
          final orbitPaint = Paint()
            ..color = Colors.grey.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawCircle(center, r, orbitPaint);

          // Draw planet
          final planetSize = maxRadius * 0.03; // Adjust size as needed
          final planetPaint = Paint()..color = Colors.blue.withOpacity(0.8);
          canvas.drawCircle(Offset(x, y), planetSize, planetPaint);

          // Draw planet name
          final textPainter = TextPainter(
            text: TextSpan(
              text: name,
              style: TextStyle(color: Colors.white, fontSize: maxRadius * 0.05),
            ),
            textDirection: ui.TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
              canvas, Offset(x + planetSize + 2, y - planetSize - 2));

          // Debug: Draw arrows pointing towards exoplanets
          final arrowPaint = Paint()
            ..color = Colors.red
            ..strokeWidth = 3;
          canvas.drawLine(center, Offset(x, y), arrowPaint);
        } else {
          print('Invalid data for exoplanet: $name');
        }
      });
    } else {
      // Fallback: Draw some placeholder exoplanets
      final placeholderExoplanets = [
        {'name': 'Exoplanet A', 'r': 0.3, 'theta': 0},
        {'name': 'Exoplanet B', 'r': 0.5, 'theta': 120},
        {'name': 'Exoplanet C', 'r': 0.7, 'theta': 240},
      ];

      for (var planet in placeholderExoplanets) {
        final r = (planet['r'] as double) * maxRadius;
        final theta = (planet['theta'] as double);
        final x = center.dx + r * math.cos(theta * math.pi / 180);
        final y = center.dy + r * math.sin(theta * math.pi / 180);

        // Draw orbit
        final orbitPaint = Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawCircle(center, r, orbitPaint);

        // Draw planet
        final planetSize = maxRadius * 0.05;
        final planetPaint = Paint()..color = Colors.red.withOpacity(0.8);
        canvas.drawCircle(Offset(x, y), planetSize, planetPaint);

        // Draw planet name
        final textPainter = TextPainter(
          text: TextSpan(
            text: planet['name'] as String,
            style: TextStyle(color: Colors.white, fontSize: maxRadius * 0.05),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
            canvas, Offset(x + planetSize + 2, y - planetSize - 2));
      }

      // Debug: Draw text indicating placeholder data
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Using placeholder data',
          style: TextStyle(color: Colors.red, fontSize: maxRadius * 0.08),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * 0.1, size.height * 0.1));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
