import 'package:flutter/material.dart';

class UcaptureScreen extends StatelessWidget {
  final Object? extra;
  const UcaptureScreen({super.key, this.extra});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF16213E),
      body: Center(child: Text('capture', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}
