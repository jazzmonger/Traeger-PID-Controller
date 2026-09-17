import 'package:flutter/material.dart';

class TempHeroes extends StatelessWidget {
  const TempHeroes({
    super.key,
    required this.setpointF,
    required this.chamberF,
    required this.onTempUp,
    required this.onTempDown,
  });

  final int setpointF;
  final double chamberF;
  final VoidCallback onTempUp;
  final VoidCallback onTempDown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _HeroColumn(
              label: 'SET',
              value: '$setpointF°',
              color: Colors.white,
              onUp: onTempUp,
              onDown: onTempDown,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _HeroColumn(
              label: 'CHAMBER',
              value: '${chamberF.round()}°',
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroColumn extends StatelessWidget {
  const _HeroColumn({
    required this.label,
    required this.value,
    required this.color,
    this.onUp,
    this.onDown,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback? onUp;
  final VoidCallback? onDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Row(
          children: [
            if (onDown != null)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                onPressed: onDown,
                visualDensity: VisualDensity.compact,
              ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onUp != null)
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
                onPressed: onUp,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }
}
