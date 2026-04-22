import 'package:flutter/material.dart';

class UprintingScreen extends StatelessWidget {
  final Object? extra;
  const UprintingScreen({super.key, this.extra});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF16213E),
      body: Center(child: Text('printing', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}
