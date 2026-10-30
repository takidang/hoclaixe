import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../shared/widgets/class_photo.dart';
import '../../../shared/widgets/motion.dart';

/// First screen when the app opens (experiment "ảnh xe"): a sports car fading into the page, the app's promise
/// and one button, "Bắt đầu", into the overview.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height;
    // light status bar icons over the dark photo, in light mode too
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // photo on the top part, fading into the page colour so the text below sits on a plain background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.6,
              child: ExcludeSemantics(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.black, Colors.transparent],
                    stops: [0, 0.55, 1],
                  ).createShader(rect),
                  child: KenBurns(
                    drift: const Offset(0.02, -0.015),
                    child: Image.asset(
                      ClassPhotos.start,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.2, 0),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Entrance(
                      index: 1,
                      child: Text(
                        S.startTitle,
                        style: text.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Entrance(
                      index: 2,
                      child: Text(
                        S.startSubtitle,
                        style: text.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Entrance(
                      index: 3,
                      child: PressScale(
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: const StadiumBorder(),
                              textStyle: text.titleMedium,
                            ),
                            onPressed: () => context.go(Routes.home),
                            child: const Text(S.startButton),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
