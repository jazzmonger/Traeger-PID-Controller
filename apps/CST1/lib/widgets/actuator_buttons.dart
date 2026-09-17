import 'package:flutter/material.dart';

class ActuatorButtons extends StatelessWidget {
  const ActuatorButtons({
    super.key,
    required this.augerOn,
    required this.hotrodOn,
    required this.primeOn,
    required this.onAuger,
    required this.onHotrod,
    required this.onPrime,
  });

  final bool augerOn;
  final bool hotrodOn;
  final bool primeOn;
  final VoidCallback onAuger;
  final VoidCallback onHotrod;
  final VoidCallback onPrime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _ActuatorButton(
              label: 'Auger',
              active: augerOn,
              color: Colors.green,
              onTap: onAuger,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActuatorButton(
              label: 'Hotrod',
              active: hotrodOn,
              color: Colors.red,
              onTap: onHotrod,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActuatorButton(
              label: 'Prime',
              active: primeOn,
              color: Colors.orange,
              onTap: onPrime,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActuatorButton extends StatelessWidget {
  const _ActuatorButton({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? color.withOpacity(0.85) : const Color(0xFF404040),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active ? Colors.white54 : Colors.white24,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
