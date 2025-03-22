import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'planet_display.dart';

void main() {
  runApp(PlanetTrackerApp());
}

class PlanetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planet Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlanetTrackerHome(),
    );
  }
}

class PlanetTrackerHome extends StatefulWidget {
  @override
  _PlanetTrackerHomeState createState() => _PlanetTrackerHomeState();
}

class _PlanetTrackerHomeState extends State<PlanetTrackerHome> {
  Map<String, dynamic>? planetData;
  final String apiEndpoint = 'http://localhost:5000/planet_positions';
  double _currentHour = 0;
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchPlanetData();
  }

  Future<void> fetchPlanetData() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_currentDate);
    try {
      final response = await http.get(Uri.parse('$apiEndpoint?date=$dateStr'));
      if (response.statusCode == 200) {
        print('Received JSON data:');
        print(const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body)));
        setState(() {
          planetData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load planet data');
      }
    } catch (e) {
      print('Error fetching planet data: $e');
    }
  }

  void _changeDate(int days) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
    });
    fetchPlanetData();
  }

  Color _getBackgroundColor(double hour) {
    final dayColor = Colors.lightBlue[100]!;
    final nightColor = Colors.blue[900]!;
    final t = (hour < 12 ? hour : 24 - hour) / 12;
    return Color.lerp(nightColor, dayColor, t)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(_currentHour),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Planet Tracker'),
            Text(DateFormat('yyyy-MM-dd').format(_currentDate)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: planetData == null
                ? Center(child: CircularProgressIndicator())
                : PlanetDisplay(
                    planetData: planetData!, currentHour: _currentHour.round()),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
            child: Column(
              children: [
                Text(
                    'Time: ${(_currentHour.round() % 24).toString().padLeft(2, '0')}:00'),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.blue.withOpacity(0.3),
                    trackShape: RoundedRectSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    thumbColor: Colors.blueAccent,
                    overlayColor: Colors.blue.withAlpha(32),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                    tickMarkShape: RoundSliderTickMarkShape(),
                    activeTickMarkColor: Colors.blue,
                    inactiveTickMarkColor: Colors.blue.withOpacity(0.3),
                    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                    valueIndicatorColor: Colors.blueAccent,
                    valueIndicatorTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: Slider(
                    value: _currentHour,
                    min: 0,
                    max: 24,
                    divisions: 24,
                    label: (_currentHour.round() % 24).toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentHour = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
