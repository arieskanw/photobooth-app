import 'package:flutter/material.dart';

class UsettingsScreen extends StatelessWidget {
  final Object? extra;
  const UsettingsScreen({super.key, this.extra});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF16213E),
      body: Center(child: Text('settings', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}
