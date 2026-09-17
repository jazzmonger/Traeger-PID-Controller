import 'package:cst1/app.dart';
import 'package:cst1/screens/home_screen.dart';
import 'package:cst1/screens/settings_screen.dart';
import 'package:cst1/services/smoker_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SmokerController> _testController() async {
  SharedPreferences.setMockInitialValues({});
  final controller = SmokerController();
  await controller.initialize(autoReconnect: false);
  return controller;
}

void main() {
  testWidgets('CST1 home shows SET and CHAMBER heroes', (tester) async {
    final controller = await _testController();

    await tester.pumpWidget(Cst1App(controller: controller));
    await tester.pump();

    expect(find.text('CST1'), findsOneWidget);
    expect(find.text('SET'), findsOneWidget);
    expect(find.text('CHAMBER'), findsOneWidget);
    expect(find.text('ON'), findsOneWidget);
    expect(find.text('Auger'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('Settings screen shows smoker ID and MQTT fields', (tester) async {
    final controller = await _testController();

    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.text('Smoker / Device ID'), findsOneWidget);
    expect(find.text('MQTT broker host'), findsOneWidget);
    expect(find.text('Home Assistant instance IP'), findsOneWidget);
    expect(find.text('Bluetooth (default)'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('Home screen includes SETTINGS mode button', (tester) async {
    final controller = await _testController();

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.text('SETTINGS'), findsOneWidget);

    controller.dispose();
  });
}
