import 'package:flutter/material.dart';

class UresultScreen extends StatelessWidget {
  final Object? extra;
  const UresultScreen({super.key, this.extra});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF16213E),
      body: Center(child: Text('result', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}
