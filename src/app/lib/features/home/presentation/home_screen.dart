import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/class_photo.dart';
import '../../../shared/widgets/equal_height_grid.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../../../shared/widgets/lane_line.dart';
import '../../../shared/widgets/motion.dart';
import '../data/home_summary_provider.dart';
import '../domain/home_summary.dart';

/// Signs from the catalog that illustrate the home cards (decorative; chosen for their meaning).
abstract final class _Signs {
  static const lanes =
      'R.411'; // Hướng đi trên mỗi làn đường phải theo: the learner's lane
  static const speed = 'R.306'; // Tốc độ tối thiểu cho phép: a timed test
  static const danger = 'W.233'; // Nguy hiểm khác: critical questions
  static const detour =
      'R.302a'; // Hướng phải đi vòng chướng ngại vật: going back over mistakes
  static const noEntry = 'P.102'; // Cấm đi ngược chiều: the best-known sign
}

/// Tab "Tổng quan" (FR-A04, ST-04; design v2): progress card with the lane line, "Thi thử", critical
/// questions, wrong answers and the sign catalog as gradient cards.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Shared by the list and the photo behind it (parallax).
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(homeSummaryProvider);
    ref.listen(
      homeSummaryProvider,
      (_, next) => _promptResume(context, ref, next.value),
    );
    final cls = summary.value?.licenseClass;
    // the header sits on the photo of the selected class (experiment "ảnh xe"): light text, translucent buttons
    final round = IconButton.styleFrom(
      backgroundColor: AppTheme.onPhotoFill,
      foregroundColor: AppTheme.onPhoto,
    );
    // the photo lies behind the whole (transparent) page, so the list still starts below the app bar
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: Theme.of(context).colorScheme.surface),
        ),
        _ClassBackdrop(photo: ClassPhotos.of(cls), scroll: _scroll),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 72,
            backgroundColor: Colors.transparent,
            systemOverlayStyle:
                SystemUiOverlayStyle.light, // icons over the photo
            foregroundColor: AppTheme.onPhoto,
            titleTextStyle: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: AppTheme.onPhoto),
            title: Text(cls == null ? S.appName : S.className(cls)),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.onPhotoFill,
                  foregroundColor: AppTheme.onPhoto,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => context.push(Routes.licenseClass),
                child: const Text(S.changeClass),
              ),
              const SizedBox(width: 6),
              IconButton(
                style: round,
                tooltip: S.searchQuestions,
                icon: const Icon(Icons.search),
                onPressed: () => context.push(Routes.search),
              ),
              IconButton(
                style: round,
                tooltip: S.about,
                icon: const Icon(Icons.info_outline),
                onPressed: () => context.push(Routes.about),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: switch (summary) {
            AsyncData(value: final s?) => _HomeBody(
              summary: s,
              scroll: _scroll,
            ),
            AsyncError() => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(S.homeError, textAlign: TextAlign.center),
              ),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}

/// The photo of the selected class behind the header: darkened at the top for the title, fading into the
/// page below; cross-fades when the class changes.
class _ClassBackdrop extends StatelessWidget {
  const _ClassBackdrop({required this.photo, required this.scroll});

  final String? photo;

  /// The list in front: the photo moves up at 40 % of its speed and fades out (parallax).
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 320 + MediaQuery.paddingOf(context).top,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: scroll,
          builder: (context, child) {
            final y = scroll.hasClients ? scroll.offset.clamp(0.0, 400.0) : 0.0;
            return Transform.translate(
              offset: Offset(0, -0.4 * y),
              child: Opacity(opacity: 1 - y / 400, child: child),
            );
          },
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.paint),
            child: photo == null
                ? const SizedBox.expand()
                : ShaderMask(
                    key: ValueKey(photo),
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.black, Colors.transparent],
                      stops: [0, 0.45, 1],
                    ).createShader(rect),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        KenBurns(child: Image.asset(photo, fit: BoxFit.cover)),
                        // darken the top so the white title reads on any photo
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppTheme.headerScrim,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.summary, required this.scroll});

  final HomeSummary summary;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = summary.openSession;
    final blocks = [
      if (open != null)
        _ResumeCard(
          sessionId: open.id,
          remaining: open.remaining(ref.watch(clockProvider)()),
        ),
      _ProgressCard(summary: summary),
      _ExamCard(summary: summary),
      EqualHeightGrid(
        columns: 2,
        spacing: 12,
        children: [
          _FeatureCard(
            tone: CardTone.amber,
            sign: _Signs.danger,
            label: S.criticalQuestions,
            detail: S.criticalHint(summary.criticalCount),
            route: Routes.critical,
          ),
          _FeatureCard(
            tone: CardTone.bloom,
            sign: _Signs.detour,
            label: S.reviewWrong,
            detail: S.wrongHint(summary.wrongCount),
            route: Routes.wrong,
          ),
        ],
      ),
      const _FeatureCard(
        wide: true,
        tone: CardTone.leaf,
        sign: _Signs.noEntry,
        label: S.trafficSigns,
        detail: S.signsHint,
        route: Routes.signs,
      ),
    ];
    return ListView(
      controller: scroll,
      padding: EdgeInsets.fromLTRB(
        16,
        96, // leaves the class photo visible under the title; the cards slide over it when scrolling
        16,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Entrance(index: i, child: blocks[i]),
        ],
      ],
    );
  }
}

/// The learner's progress: a lane marking, dashed until each question is answered right (kept from v1).
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.cardText(context);
    final count = '${summary.correctCount}';
    return GradientCard(
      tone: CardTone.sunset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.studyProgress, style: text.titleLarge),
                    const SizedBox(height: 4),
                    CountUp(
                      value: summary.correctCount,
                      builder: (context, shown) => Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$shown',
                              style: AppTheme.mono(
                                text.headlineLarge,
                                CardPalette.of(context).ink,
                              ),
                            ),
                            TextSpan(
                              text: S
                                  .progressCount(
                                    summary.correctCount,
                                    summary.poolSize,
                                  )
                                  .substring(count.length),
                              style: text.titleSmall?.copyWith(
                                color: CardPalette.of(context).inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SignBadge(code: _Signs.lanes),
            ],
          ),
          const SizedBox(height: 16),
          LaneLine.progress(
            value: summary.progress,
            color: CardPalette.of(context).ink,
            thickness: 5,
            semanticsLabel: S.progressCount(
              summary.correctCount,
              summary.poolSize,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            S.progressHint,
            style: text.bodySmall?.copyWith(
              color: CardPalette.of(context).inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

/// The main action of the tab.
class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.cardText(context);
    final s = summary.structure;
    return GradientCard(
      tone: CardTone.sky,
      onTap: () => context.push(Routes.exam),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.practiceExam, style: text.headlineSmall),
                if (s != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    S.examCta(
                      summary.licenseClass,
                      s.questionCount,
                      s.durationMinutes,
                    ),
                    style: text.bodyMedium?.copyWith(
                      color: CardPalette.of(context).inkSoft,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SignBadge(code: _Signs.speed),
        ],
      ),
    );
  }
}

/// A gradient card that opens a feature: sign above the text when [wide] is false (half width),
/// beside it when true (full width).
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.tone,
    required this.sign,
    required this.label,
    required this.detail,
    required this.route,
    this.wide = false,
  });

  final CardTone tone;
  final String sign;
  final String label;
  final String detail;
  final String route;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.cardText(context);
    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: wide ? text.titleLarge : text.titleMedium),
        const SizedBox(height: 2),
        Text(
          detail,
          style: text.bodySmall?.copyWith(
            color: CardPalette.of(context).inkSoft,
          ),
        ),
      ],
    );
    return GradientCard(
      tone: tone,
      padding: EdgeInsets.all(wide ? 20 : 16),
      onTap: () => context.push(route),
      child: wide
          ? Row(
              children: [
                Expanded(child: words),
                SignBadge(code: sign, size: 56),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SignBadge(code: sign, size: 52),
                const SizedBox(height: 20),
                words,
              ],
            ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.sessionId, required this.remaining});

  final int sessionId;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline),
        title: const Text(S.resumeExam),
        subtitle: Text(
          remaining == Duration.zero ? S.examTimeUp : S.timeLeft(remaining),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.examSession(sessionId)),
      ),
    );
  }
}

/// Asked once, when the app opens with an unfinished test (ST-09 AC3). A test past its deadline is opened
/// directly: the exam screen submits it and shows the result (FR-A25).
class _ResumePrompt {
  bool shown = false;
}

final _resumePromptProvider = Provider<_ResumePrompt>((ref) => _ResumePrompt());

Future<void> _promptResume(
  BuildContext context,
  WidgetRef ref,
  HomeSummary? summary,
) async {
  final prompt = ref.read(_resumePromptProvider);
  // decided once, on the first home data after start — not when coming back from "Lưu tạm và thoát"
  if (summary == null || prompt.shown) return;
  prompt.shown = true;
  final open = summary.openSession;
  if (open == null) return;
  final left = open.remaining(ref.read(clockProvider)());
  if (left == Duration.zero) {
    await context.push(Routes.examSession(open.id));
    return;
  }
  final resume = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(S.resumePromptTitle),
      content: Text(S.resumePromptBody(open.paper.licenseClass, left)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(S.later),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(S.resume),
        ),
      ],
    ),
  );
  if (resume == true && context.mounted) {
    await context.push(Routes.examSession(open.id));
  }
}
