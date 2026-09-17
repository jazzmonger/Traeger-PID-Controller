import 'dart:math' as math;

import 'package:flutter/material.dart';

class ChamberGraph extends StatelessWidget {
  const ChamberGraph({
    super.key,
    required this.history,
    required this.setpointF,
    required this.zoom,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final List<double> history;
  final int setpointF;
  final double zoom;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Chamber',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Spacer(),
              IconButton(
                onPressed: onZoomOut,
                icon: const Icon(Icons.zoom_out, color: Colors.white54, size: 20),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onZoomIn,
                icon: const Icon(Icons.zoom_in, color: Colors.white54, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Container(
            height: 72,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              color: Colors.black,
            ),
            child: CustomPaint(
              painter: _GraphPainter(
                history: history,
                setpoint: setpointF.toDouble(),
                zoom: zoom,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.history,
    required this.setpoint,
    required this.zoom,
  });

  final List<double> history;
  final double setpoint;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) {
      final text = TextPainter(
        text: const TextSpan(
          text: 'No data',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
        canvas,
        Offset((size.width - text.width) / 2, (size.height - text.height) / 2),
      );
      return;
    }

    final span = 40.0 / zoom;
    final minY = math.min(
      history.reduce(math.min),
      setpoint - span / 2,
    );
    final maxY = math.max(
      history.reduce(math.max),
      setpoint + span / 2,
    );
    final range = (maxY - minY).clamp(20.0, 500.0);

    final setpointPaint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..strokeWidth = 1;
    final ySp = size.height - ((setpoint - minY) / range) * size.height;
    canvas.drawLine(Offset(0, ySp), Offset(size.width, ySp), setpointPaint);

    final linePaint = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final count = history.length;
    for (var i = 0; i < count; i++) {
      final x = count <= 1 ? 0.0 : (i / (count - 1)) * size.width;
      final y = size.height - ((history[i] - minY) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.setpoint != setpoint ||
        oldDelegate.zoom != zoom;
  }
}
