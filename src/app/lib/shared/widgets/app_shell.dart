import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../core/theme/app_theme.dart';

/// The four tabs (design v2): Tổng quan · Học · Câu đã lưu · Thống kê, in a floating pill at the bottom.
/// Other screens (a topic, a test, signs…) open over it, full screen.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (Icons.grid_view_rounded, S.tabOverview),
    (Icons.menu_book_outlined, S.studyByTopic),
    (Icons.bookmark_border, S.savedQuestions),
    (Icons.insights_outlined, S.statistics),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

/// Switching tabs fades the new tab in from 98.5 % size ("fade through"), each tab keeping its state.
class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _switch = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: 1,
  );
  late final Animation<double> _in = CurvedAnimation(
    parent: _switch,
    curve: AppMotion.quickCurve,
  );
  late final Animation<double> _scale = Tween(
    begin: 0.985,
    end: 1.0,
  ).animate(_in);

  StatefulNavigationShell get shell => widget.shell;

  @override
  void didUpdateWidget(AppShell old) {
    super.didUpdateWidget(old);
    if (old.shell.currentIndex != shell.currentIndex) {
      _switch.duration = AppMotion.of(
        context,
        const Duration(milliseconds: 280),
      );
      _switch.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _switch.dispose();
    super.dispose();
  }

  void _open(int i) {
    HapticFeedback.selectionClick();
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    // Android back on another tab returns to "Tổng quan" before leaving the app
    canPop: shell.currentIndex == 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) shell.goBranch(0);
    },
    child: Scaffold(
      body: FadeTransition(
        opacity: _in,
        child: ScaleTransition(
          scale: _scale,
          child: shell,
        ),
      ),
      extendBody: true, // tab screens scroll under the pill; they pad by MediaQuery's bottom inset
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Center(
            heightFactor: 1,
            child: _Pill(current: shell.currentIndex, onTap: _open),
          ),
        ),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.current, required this.onTap});

  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.inverseSurface,
      elevation: 6,
      shadowColor: Colors.black54,
      shape: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < AppShell._tabs.length; i++)
              _Tab(
                icon: AppShell._tabs[i].$1,
                label: AppShell._tabs[i].$2,
                selected: i == current,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.quick),
            curve: AppMotion.quickCurve,
            width: 64,
            height: 52,
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: selected ? scheme.onInverseSurface : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: selected ? scheme.inverseSurface : scheme.onInverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}
