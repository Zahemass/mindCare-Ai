import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Companion')),
      body: const Center(child: Text('AI Chat Screen Coming Soon')),
    );
  }
}

class SelfCareScreen extends StatelessWidget {
  const SelfCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Self Care')),
      body: const Center(child: Text('Self Care Activities Coming Soon')),
    );
  }
}
