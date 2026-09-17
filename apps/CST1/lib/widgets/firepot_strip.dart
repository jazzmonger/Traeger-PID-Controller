import 'package:flutter/material.dart';

class FirepotStrip extends StatelessWidget {
  const FirepotStrip({
    super.key,
    required this.firepotF,
    required this.lighting,
    required this.priming,
  });

  final double firepotF;
  final bool lighting;
  final bool priming;

  @override
  Widget build(BuildContext context) {
    final label = lighting
        ? 'Lighting…'
        : priming
            ? 'Priming…'
            : 'Firepot ${firepotF.round()}°F';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade900,
            lighting || priming ? Colors.orange : Colors.red.shade700,
            Colors.red.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(
            lighting ? Icons.local_fire_department : Icons.whatshot,
            color: Colors.orangeAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
