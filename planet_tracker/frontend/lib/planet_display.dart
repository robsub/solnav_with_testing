import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class PlanetDisplay extends StatefulWidget {
  final Map<String, dynamic> planetData;
  final int currentHour;
  final double centerAzimuth;

  PlanetDisplay({
    required this.planetData,
    required this.currentHour,
    required this.centerAzimuth,
  });

  @override
  _PlanetDisplayState createState() => _PlanetDisplayState();
}

class _PlanetDisplayState extends State<PlanetDisplay>
    with SingleTickerProviderStateMixin {
  String? hoveredPlanet;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => setState(() => hoveredPlanet = null),
      child: CustomPaint(
        painter: PlanetPainter(
          planetData: widget.planetData,
          currentHour: widget.currentHour,
          hoveredPlanet: hoveredPlanet,
          animation: _animation,
          centerAzimuth: widget.centerAzimuth,
        ),
        child: Stack(
          children: widget.planetData['planets'].keys.map<Widget>((planetName) {
            final positions = widget.planetData['planets'][planetName];
            final position = positions[widget.currentHour];
            final adjustedAzimuth =
                (position['azimuth'] - widget.centerAzimuth + 540) % 360 - 180;
            final x = MediaQuery.of(context).size.width *
                (adjustedAzimuth + 180) /
                360;
            final y = MediaQuery.of(context).size.height *
                (1 - position['altitude'] / 90);
            return Positioned(
              left: x - 40,
              top: y - 40,
              child: MouseRegion(
                onEnter: (_) {
                  setState(() => hoveredPlanet = planetName);
                  _controller.forward(from: 0);
                },
                onExit: (_) {
                  setState(() => hoveredPlanet = null);
                  _controller.reverse(from: 1);
                },
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class PlanetPainter extends CustomPainter {
  final Map<String, dynamic> planetData;
  final int currentHour;
  final String? hoveredPlanet;
  final Animation<double> animation;
  final double centerAzimuth;

  PlanetPainter({
    required this.planetData,
    required this.currentHour,
    required this.hoveredPlanet,
    required this.animation,
    required this.centerAzimuth,
  });

  Color getPlanetColor(String planetName) {
    switch (planetName.toLowerCase()) {
      case 'mars':
        return Colors.red;
      case 'jupiter barycenter':
        return Colors.orange;
      case 'saturn barycenter':
        return Colors.yellow;
      case 'venus':
        return Colors.yellowAccent;
      case 'mercury':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  double getPlanetSize(String planetName) {
    switch (planetName.toLowerCase()) {
      case 'jupiter barycenter':
        return 80.0;
      case 'saturn barycenter':
        return 68.0;
      case 'mars':
        return 40.0;
      case 'venus':
        return 60.0;
      case 'mercury':
        return 28.0;
      default:
        return 20.0;
    }
  }

  String formatPlanetName(String planetName) {
    return planetName.split(' ')[0].capitalize();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    planetData['planets'].forEach((planetName, positions) {
      final position = positions[currentHour];
      final adjustedAzimuth =
          (position['azimuth'] - centerAzimuth + 540) % 360 - 180;
      final x = size.width * (adjustedAzimuth + 180) / 360;
      final y = size.height * (1 - position['altitude'] / 90);

      paint.color = getPlanetColor(planetName);
      final baseSize = getPlanetSize(planetName);
      final planetSize =
          planetName == hoveredPlanet ? baseSize * animation.value : baseSize;
      canvas.drawCircle(
        Offset(x, y),
        planetSize / 2,
        paint,
      );

      // Draw planet name
      final formattedName = formatPlanetName(planetName);
      final textPainter = TextPainter(
        text: TextSpan(
          text: formattedName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y + planetSize / 2 + 5),
      );

      if (planetName == hoveredPlanet) {
        final hoverTextPainter = TextPainter(
          text: TextSpan(
            text: formattedName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        hoverTextPainter.layout();
        hoverTextPainter.paint(
          canvas,
          Offset(x + planetSize / 2 + 5, y - 7),
        );
      }
    });
  }

  @override
  bool shouldRepaint(covariant PlanetPainter oldDelegate) =>
      oldDelegate.currentHour != currentHour ||
      oldDelegate.hoveredPlanet != hoveredPlanet ||
      oldDelegate.animation.value != animation.value ||
      oldDelegate.centerAzimuth != centerAzimuth;
}
