import 'package:flutter/material.dart';

class PlanetDisplay extends StatefulWidget {
  final Map<String, dynamic> planetData;
  final int currentHour;

  PlanetDisplay({required this.planetData, required this.currentHour});

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
            widget.planetData, widget.currentHour, hoveredPlanet, _animation),
        child: Stack(
          children: widget.planetData['planets'].keys.map<Widget>((planetName) {
            final positions = widget.planetData['planets'][planetName];
            final position = positions[widget.currentHour];
            final x =
                MediaQuery.of(context).size.width * position['azimuth'] / 360;
            final y = MediaQuery.of(context).size.height *
                (1 - position['altitude'] / 90);
            return Positioned(
              left: x - 20,
              top: y - 20,
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
                  width: 40,
                  height: 40,
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

  PlanetPainter(
      this.planetData, this.currentHour, this.hoveredPlanet, this.animation);

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
        return 40.0;
      case 'saturn barycenter':
        return 34.0;
      case 'mars':
        return 20.0;
      case 'venus':
        return 30.0;
      case 'mercury':
        return 14.0;
      default:
        return 10.0;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    planetData['planets'].forEach((planetName, positions) {
      final position = positions[currentHour];
      final x = size.width * position['azimuth'] / 360;
      final y = size.height * (1 - position['altitude'] / 90);

      paint.color = getPlanetColor(planetName);
      final baseSize = getPlanetSize(planetName);
      final planetSize =
          planetName == hoveredPlanet ? baseSize * animation.value : baseSize;
      canvas.drawCircle(
        Offset(x, y),
        planetSize,
        paint,
      );

      if (planetName == hoveredPlanet) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: planetName,
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + planetSize + 5, y - 7));
      }
    });
  }

  @override
  bool shouldRepaint(covariant PlanetPainter oldDelegate) =>
      oldDelegate.currentHour != currentHour ||
      oldDelegate.hoveredPlanet != hoveredPlanet ||
      oldDelegate.animation.value != animation.value;
}
