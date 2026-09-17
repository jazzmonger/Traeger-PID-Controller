import 'package:flutter/material.dart';

class SmokePRow extends StatelessWidget {
  const SmokePRow({
    super.key,
    required this.pLabel,
    required this.onPUp,
    required this.onPDown,
  });

  final String pLabel;
  final VoidCallback onPUp;
  final VoidCallback onPDown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Text('Smoke', style: TextStyle(color: Colors.white, fontSize: 18)),
          const Spacer(),
          IconButton(
            onPressed: onPDown,
            icon: const Icon(Icons.remove, color: Colors.white70),
          ),
          Text(
            pLabel,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: onPUp,
            icon: const Icon(Icons.add, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
