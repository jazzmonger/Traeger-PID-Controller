import 'package:flutter/material.dart';

class ModeButtonsRow extends StatelessWidget {
  const ModeButtonsRow({
    super.key,
    required this.powerOn,
    required this.smokeMode,
    required this.onPower,
    required this.onHeat,
    required this.onSmoke,
    required this.onSettings,
  });

  final bool powerOn;
  final bool smokeMode;
  final VoidCallback onPower;
  final VoidCallback onHeat;
  final VoidCallback onSmoke;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ModeChip(
            label: 'ON',
            active: powerOn,
            activeColor: const Color(0xFF00C800),
            onTap: onPower,
          ),
          _ModeChip(
            label: 'Heat',
            active: powerOn && !smokeMode,
            activeColor: const Color(0xFF00C800),
            onTap: onHeat,
          ),
          _ModeChip(
            label: 'Smoke',
            active: smokeMode,
            activeColor: const Color(0xFF0000C8),
            onTap: onSmoke,
          ),
          _ModeChip(
            label: 'SETTINGS',
            active: false,
            activeColor: Colors.grey,
            onTap: onSettings,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = active ? activeColor : const Color(0xFF505050);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
          boxShadow: active
              ? [
                  const BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0, 2),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 11 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
