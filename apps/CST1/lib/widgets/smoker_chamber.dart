import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Visual chamber diagram inspired by the on-device 240×320 UI (fan + hotrod strip).
class SmokerChamber extends StatelessWidget {
  const SmokerChamber({
    super.key,
    required this.augerOn,
    required this.hotrodOn,
    required this.pLabel,
  });

  final bool augerOn;
  final bool hotrodOn;
  final String pLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 12,
            top: 8,
            child: Text(
              'Smoker',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Positioned(
            left: 32,
            bottom: 12,
            child: Text(
              pLabel,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 12,
            child: _FanIcon(spinning: augerOn),
          ),
          Positioned(
            right: 16,
            bottom: 8,
            child: Container(
              width: 36,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: hotrodOn
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 12,
                        color: Colors.red,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FanIcon extends StatefulWidget {
  const _FanIcon({required this.spinning});

  final bool spinning;

  @override
  State<_FanIcon> createState() => _FanIconState();
}

class _FanIconState extends State<_FanIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.spinning) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _FanIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.spinning && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.spinning ? _controller.value * 2 * math.pi : 0,
          child: child,
        );
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green),
        ),
        child: const Icon(Icons.air, color: Colors.greenAccent, size: 20),
      ),
    );
  }
}
