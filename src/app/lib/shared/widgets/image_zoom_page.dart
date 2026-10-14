import 'package:flutter/material.dart';

import '../../core/strings.dart';

/// Full-screen image (FR-A12): pinch to zoom up to [maxScale], drag to pan;
/// double tap resets the zoom, or goes back when not zoomed.
class ImageZoomPage extends StatefulWidget {
  const ImageZoomPage({super.key, required this.asset});

  final String asset;

  static const maxScale = 4.0;

  static Future<void> open(BuildContext context, String asset) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => ImageZoomPage(asset: asset),
        ),
      );

  @override
  State<ImageZoomPage> createState() => _ImageZoomPageState();
}

class _ImageZoomPageState extends State<ImageZoomPage> {
  final _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (_controller.value.getMaxScaleOnAxis() > 1.01) {
      _controller.value = Matrix4.identity();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.scrim,
      appBar: AppBar(
        backgroundColor: scheme.scrim,
        foregroundColor: scheme.onInverseSurface,
        leading: IconButton(
          tooltip: S.close,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onDoubleTap: _onDoubleTap,
        child: InteractiveViewer(
          transformationController: _controller,
          maxScale: ImageZoomPage.maxScale,
          child: Center(
            child: Semantics(
              label: S.questionImage,
              image: true,
              child: Image.asset(widget.asset, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
