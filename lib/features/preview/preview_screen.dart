import 'package:flutter/material.dart';

class UpreviewScreen extends StatelessWidget {
  final Object? extra;
  const UpreviewScreen({super.key, this.extra});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF16213E),
      body: Center(child: Text('preview', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}
