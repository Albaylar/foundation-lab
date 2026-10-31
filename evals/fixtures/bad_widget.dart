import 'package:flutter/material.dart';

class BadCard extends StatelessWidget {
  const BadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF6C4CF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Hi', style: TextStyle(color: Colors.white)),
    );
  }
}
