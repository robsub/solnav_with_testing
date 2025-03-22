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
  double _sliderValue = 0; // This represents hours from midnight
  double _azimuthValue = 180; // Default to south-facing
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
    final dayColor = Colors.blue[700]!; // Darker blue for day
    final nightColor = Colors.blue[900]!; // Dark blue for night
    final t = (hour < 12 ? hour : 24 - hour) / 12;
    return Color.lerp(nightColor, dayColor, t)!;
  }

  String _formatHour(double value) {
    int hour = (value.round() + 24) % 24;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  String _formatAzimuth(double value) {
    return '${value.round()}°';
  }

  String _getDirectionName(double azimuth) {
    if (azimuth >= 337.5 || azimuth < 22.5) return 'N';
    if (azimuth >= 22.5 && azimuth < 67.5) return 'NE';
    if (azimuth >= 67.5 && azimuth < 112.5) return 'E';
    if (azimuth >= 112.5 && azimuth < 157.5) return 'SE';
    if (azimuth >= 157.5 && azimuth < 202.5) return 'S';
    if (azimuth >= 202.5 && azimuth < 247.5) return 'SW';
    if (azimuth >= 247.5 && azimuth < 292.5) return 'W';
    return 'NW';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor((_sliderValue + 24) % 24),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Planet Tracker'),
            Text(
              '${DateFormat('yyyy-MM-dd').format(_currentDate)} - Facing: ${_formatAzimuth(_azimuthValue)} (${_getDirectionName(_azimuthValue)})',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: planetData == null
                ? Center(child: CircularProgressIndicator())
                : PlanetDisplay(
                    planetData: planetData!,
                    currentHour: (_sliderValue.round() + 24) % 24,
                    centerAzimuth: _azimuthValue,
                  ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
            child: Column(
              children: [
                Text('Time: ${_formatHour(_sliderValue)}',
                    style: TextStyle(color: Colors.white)),
                Container(
                  width: 200,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue[300],
                      inactiveTrackColor: Colors.blue[100]!.withOpacity(0.3),
                      trackShape: RoundedRectSliderTrackShape(),
                      trackHeight: 4.0,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      thumbColor: Colors.blueAccent,
                      overlayColor: Colors.blue.withAlpha(32),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 28.0),
                      tickMarkShape: RoundSliderTickMarkShape(),
                      activeTickMarkColor: Colors.blue[300],
                      inactiveTickMarkColor: Colors.blue[100]!.withOpacity(0.3),
                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      valueIndicatorColor: Colors.blueAccent,
                      valueIndicatorTextStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    child: Slider(
                      value: _sliderValue,
                      min: -12,
                      max: 12,
                      divisions: 24,
                      label: _formatHour(_sliderValue),
                      onChanged: (double value) {
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                    'Direction: ${_formatAzimuth(_azimuthValue)} (${_getDirectionName(_azimuthValue)})',
                    style: TextStyle(color: Colors.white)),
                Container(
                  width: 200,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.green[300],
                      inactiveTrackColor: Colors.green[100]!.withOpacity(0.3),
                      trackShape: RoundedRectSliderTrackShape(),
                      trackHeight: 4.0,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      thumbColor: Colors.greenAccent,
                      overlayColor: Colors.green.withAlpha(32),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 28.0),
                      tickMarkShape: RoundSliderTickMarkShape(),
                      activeTickMarkColor: Colors.green[300],
                      inactiveTickMarkColor:
                          Colors.green[100]!.withOpacity(0.3),
                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      valueIndicatorColor: Colors.greenAccent,
                      valueIndicatorTextStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    child: Slider(
                      value: _azimuthValue,
                      min: 0,
                      max: 360,
                      divisions: 360,
                      label: _formatAzimuth(_azimuthValue),
                      onChanged: (double value) {
                        setState(() {
                          _azimuthValue = value;
                        });
                      },
                    ),
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
