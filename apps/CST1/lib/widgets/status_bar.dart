import 'package:flutter/material.dart';

import '../ble/ble_protocol.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
    required this.message,
    required this.linkStatus,
    this.pelletPercent,
  });

  final String message;
  final LinkStatus linkStatus;
  final int? pelletPercent;

  @override
  Widget build(BuildContext context) {
    final linkColor = switch (linkStatus) {
      LinkStatus.connected => Colors.greenAccent,
      LinkStatus.connecting || LinkStatus.scanning => Colors.amberAccent,
      LinkStatus.error => Colors.redAccent,
      LinkStatus.disconnected => Colors.grey,
    };

    return Container(
      width: double.infinity,
      color: const Color(0xFF505050),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: linkColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (pelletPercent != null)
            Text(
              '$pelletPercent%',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
