import 'package:cst1/ble/ble_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmokerState.parse', () {
    test('parses full 1-pot CSV status', () {
      const raw =
          '107.2,148.9,225,300,225,1,0,2,1,0,0,75,0,0,Pot Lit';
      final s = SmokerState.parse(raw);

      expect(s.chamberC, 107.2);
      expect(s.firepotC, 148.9);
      expect(s.chamberF, 225);
      expect(s.firepotF, 300);
      expect(s.setpointF, 225);
      expect(s.powerOn, isTrue);
      expect(s.smokeMode, isFalse);
      expect(s.pIndex, 2);
      expect(s.augerOn, isTrue);
      expect(s.hotrodOn, isFalse);
      expect(s.pelletPercent, 75);
      expect(s.lighting, isFalse);
      expect(s.statusMessage, 'Pot Lit');
      expect(s.pLabel, 'P2');
      expect(s.cookMode, CookMode.heat);
    });

    test('returns disconnected for short payloads', () {
      expect(SmokerState.parse('1,2,3'), SmokerState.disconnected);
    });

    test('handles dash pellet level', () {
      const raw = '0,0,0,0,225,0,1,0,0,0,0,-,0,0,Idle';
      final s = SmokerState.parse(raw);
      expect(s.pelletPercent, isNull);
      expect(s.smokeMode, isTrue);
      expect(s.cookMode, CookMode.off);
    });
  });

  group('Cst1BleCommands', () {
    test('setpoint command format', () {
      expect(Cst1BleCommands.setpointF(225), 'SPF 225');
    });
  });
}
