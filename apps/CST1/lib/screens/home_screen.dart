import 'package:flutter/material.dart';

import '../services/smoker_controller.dart';
import '../widgets/actuator_buttons.dart';
import '../widgets/chamber_graph.dart';
import '../widgets/firepot_strip.dart';
import '../widgets/mode_buttons.dart';
import '../widgets/smoke_p_row.dart';
import '../widgets/smoker_chamber.dart';
import '../widgets/status_bar.dart';
import '../widgets/temp_heroes.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final SmokerController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() => setState(() {});

  Future<void> _cmd(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final s = c.state;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('CST1', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsScreen(controller: c),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ModeButtonsRow(
              powerOn: s.powerOn,
              smokeMode: s.smokeMode,
              onPower: () => _cmd(c.togglePower),
              onHeat: () => _cmd(c.setHeatMode),
              onSmoke: () => _cmd(c.setSmokeMode),
              onSettings: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SettingsScreen(controller: c),
                  ),
                );
              },
            ),
            TempHeroes(
              setpointF: s.setpointF,
              chamberF: s.chamberF,
              onTempUp: () => _cmd(c.tempUp),
              onTempDown: () => _cmd(c.tempDown),
            ),
            SmokePRow(
              pLabel: s.pLabel,
              onPUp: () => _cmd(c.pUp),
              onPDown: () => _cmd(c.pDown),
            ),
            ChamberGraph(
              history: c.chamberHistory,
              setpointF: s.setpointF,
              zoom: c.graphZoom,
              onZoomIn: c.zoomGraphIn,
              onZoomOut: c.zoomGraphOut,
            ),
            FirepotStrip(
              firepotF: s.firepotF,
              lighting: s.lighting,
              priming: s.priming,
            ),
            SmokerChamber(
              augerOn: s.augerOn,
              hotrodOn: s.hotrodOn,
              pLabel: s.pLabel,
            ),
            ActuatorButtons(
              augerOn: s.augerOn,
              hotrodOn: s.hotrodOn,
              primeOn: s.primeOn,
              onAuger: () => _cmd(c.toggleAuger),
              onHotrod: () => _cmd(c.toggleHotrod),
              onPrime: () => _cmd(c.prime),
            ),
              const SizedBox(height: 8),
              StatusBar(
                message: s.statusMessage,
                linkStatus: c.linkStatus,
                pelletPercent: s.pelletPercent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
