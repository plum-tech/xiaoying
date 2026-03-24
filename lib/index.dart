import 'package:flutter/material.dart';

class MainStagePage extends StatelessWidget {
  final Widget child;

  const MainStagePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
