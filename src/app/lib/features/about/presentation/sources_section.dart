import 'package:flutter/material.dart';

import '../../../core/strings.dart';

/// Official sources of the content (FR-A01, FR-A02).
class SourcesSection extends StatelessWidget {
  const SourcesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.sourcesTitle, style: text.titleMedium),
        const SizedBox(height: 8),
        for (final source in S.sources)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('• $source', style: text.bodyMedium),
          ),
        const SizedBox(height: 4),
        SelectableText(S.officialSite, style: text.bodyMedium),
        const SizedBox(height: 12),
        Text(S.photoCredits, style: text.bodySmall),
      ],
    );
  }
}
