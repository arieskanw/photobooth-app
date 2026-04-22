import 'package:flutter/material.dart';

class UhomeScreen extends StatelessWidget {
  final Object? extra;
  const UhomeScreen({super.key, this.extra});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF16213E),
      body: Center(child: Text('home', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}
