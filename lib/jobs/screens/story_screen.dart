import 'dart:async';
import 'package:flutter/material.dart';
import '../../common/widgets/app_loading_indicator.dart';
import '../models/story_model.dart';
import '../widgets/expandable_text.dart';
import '../widgets/segment_bar.dart';

class StoryViewer extends StatefulWidget {
  final List<StoryItemModel> stories;
  final int initialIndex;
  final VoidCallback? onClose;
  final ValueChanged<int>? onIndexChanged;

  const StoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.onClose,
    this.onIndexChanged,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late int _index;
  late AnimationController _progress;

  StoryItemModel get _current => widget.stories[_index];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _progress = AnimationController(vsync: this, duration: _current.duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      })
      ..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onIndexChanged?.call(_index);
      _precacheAround(_index);
    });
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _progress
      ..stop()
      ..duration = _current.duration
      ..reset()
      ..forward();
  }

  void _pause() => _progress.stop();
  void _resume() => _progress.forward();

  void _jumpTo(int i) {
    setState(() => _index = i);
    widget.onIndexChanged?.call(_index);
    _restartTimer();
    _precacheAround(_index);
  }

  void _next() {
    if (_index < widget.stories.length - 1) {
      _jumpTo(_index + 1);
    } else {
      widget.onClose?.call();
      Navigator.of(context).maybePop();
    }
  }

  void _prev() {
    if (_index > 0) {
      _jumpTo(_index - 1);
    } else {
      _restartTimer();
    }
  }

  Future<void> _precacheAround(int i) async {
    Future<void> _pre(int idx) async {
      if (idx < 0 || idx >= widget.stories.length) return;
      final url = widget.stories[idx].imageUrl;
      final provider = NetworkImage(url);
      try {
        await precacheImage(provider, context);
      } catch (_) {}
    }

    unawaited(_pre(i));
    unawaited(_pre(i + 1));
    unawaited(_pre(i - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Tap zones
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: _StoryContent(
                    key: ValueKey(_index),
                    item: _current,
                    onPrev: _prev,
                    onNext: _next,
                    onPause: _pause,
                    onResume: _resume,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 12,
              right: 12,
              top: 8,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  return Stack(
                    children: [
                      // Segments
                      Row(
                        children: [
                          for (int i = 0; i < widget.stories.length; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: SegmentBar(
                                  value: i < _index
                                      ? 1.0
                                      : (i == _index ? _progress.value : 0.0),
                                  activeColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  bgColor: Colors.white24,
                                ),
                              ),
                            ),
                        ],
                      ),

                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            widget.onClose?.call();
                            Navigator.of(context).maybePop();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryContent extends StatelessWidget {
  final StoryItemModel item;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const _StoryContent({
    super.key,
    required this.item,
    required this.onPrev,
    required this.onNext,
    required this.onPause,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: 32),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        gaplessPlayback: true,
                        loadingBuilder: (c, w, p) {
                          if (p == null) return w;
                          return Container(
                            color: Colors.white10,
                            alignment: Alignment.center,
                            child: const AppLoadingIndicator.inline(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white10,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) {
                        final w = constraints.maxWidth;
                        if (d.localPosition.dx < w * 0.33) {
                          onPrev();
                        } else {
                          onNext();
                        }
                      },
                      onLongPress: onPause,
                      onLongPressUp: onResume,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          color: Colors.black.withOpacity(0.45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: txt.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ExpandableText(
                text: item.description,
                trimLines: 3,
                style: txt.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                linkStyle: txt.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
