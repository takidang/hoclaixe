import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/models.dart';
import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../domain/sign_search.dart';
import 'sign_image.dart';

/// "Biển báo" (ST-12 FR-A30): one tab per group of QCVN 41:2024; search by code or name (ST-16 FR-A31).
class SignCatalogScreen extends ConsumerStatefulWidget {
  const SignCatalogScreen({super.key});

  @override
  ConsumerState<SignCatalogScreen> createState() => _SignCatalogScreenState();
}

class _SignCatalogScreenState extends ConsumerState<SignCatalogScreen> {
  final _query = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider).value;
    if (content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final groups = content.signGroups.entries
        .where((g) => content.signs.any((s) => s.group == g.key))
        .toList();
    return DefaultTabController(
      length: groups.length,
      child: Scaffold(
        appBar: AppBar(
          title: _searching
              ? TextField(
                  controller: _query,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: S.searchHint,
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                )
              : const Text(S.trafficSigns),
          actions: [
            IconButton(
              tooltip: _searching ? S.closeSearch : S.searchSigns,
              icon: Icon(_searching ? Icons.close : Icons.search),
              onPressed: () => setState(() {
                _searching = !_searching;
                _query.clear();
              }),
            ),
          ],
          bottom: _searching
              ? null
              : TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [for (final g in groups) Tab(text: g.value)],
                ),
        ),
        body: _searching
            ? _SearchResults(
                signs: searchSigns(content.signs, _query.text),
                typed: _query.text.trim().isNotEmpty,
              )
            : TabBarView(
                children: [
                  for (final g in groups)
                    _SignList(
                      signs: [
                        for (final s in content.signs)
                          if (s.group == g.key) s,
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.signs, required this.typed});

  final List<TrafficSign> signs;
  final bool typed;

  @override
  Widget build(BuildContext context) {
    if (!typed) return const SizedBox.shrink();
    if (signs.isEmpty) return const Center(child: Text(S.noSignFound));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            S.searchResults(signs.length),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(child: _SignList(signs: signs, showGroup: true)),
      ],
    );
  }
}

class _SignList extends StatelessWidget {
  const _SignList({required this.signs, this.showGroup = false});

  final List<TrafficSign> signs;
  final bool showGroup;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: signs.length,
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: (context, i) =>
        _SignTile(sign: signs[i], showGroup: showGroup),
  );
}

class _SignTile extends StatelessWidget {
  const _SignTile({required this.sign, required this.showGroup});

  final TrafficSign sign;
  final bool showGroup;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.sign(sign.code)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SignImage(sign: sign, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sign.code,
                      style: text.labelLarge?.copyWith(color: scheme.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(sign.name, style: text.titleSmall),
                    if (showGroup)
                      Text(
                        sign.groupName,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    if (sign.summary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        sign.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
