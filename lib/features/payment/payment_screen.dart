import 'package:flutter/material.dart';

class UpaymentScreen extends StatelessWidget {
  final Object? extra;
  const UpaymentScreen({super.key, this.extra});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF16213E),
      body: Center(child: Text('payment', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}
