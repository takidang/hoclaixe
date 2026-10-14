import 'package:flutter/material.dart';

import '../../../core/strings.dart';

/// Placeholder for features built in later stories (ST-06, ST-07, ST-08, ST-12).
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: const Center(child: Text(S.comingSoon)),
  );
}
