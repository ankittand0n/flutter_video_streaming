import 'package:flutter/material.dart';


class NetflixScaffold extends StatelessWidget {
  const NetflixScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
