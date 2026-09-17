import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/smoker_controller.dart';

class Cst1App extends StatefulWidget {
  const Cst1App({super.key, this.controller});

  final SmokerController? controller;

  @override
  State<Cst1App> createState() => _Cst1AppState();
}

class _Cst1AppState extends State<Cst1App> {
  late final SmokerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SmokerController();
    if (widget.controller != null) {
      _ready = true;
    } else {
      _controller.initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CST1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _ready
          ? HomeScreen(controller: _controller)
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
