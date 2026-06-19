import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;
  final TextStyle? linkStyle;

  const ExpandableText({
    required this.text,
    this.trimLines = 3,
    this.style,
    this.linkStyle,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  bool _overflowing = false;

  static final RegExp _urlPattern = RegExp(
    r'((?:https?:\/\/|www\.)[^\s]+)',
    caseSensitive: false,
  );

  Uri? _normalizeUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final withScheme =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';

    return Uri.tryParse(withScheme);
  }

  Future<void> _openUrl(String rawUrl) async {
    final uri = _normalizeUrl(rawUrl);
    if (uri == null) return;

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  List<InlineSpan> _buildTextSpans() {
    final spans = <InlineSpan>[];
    var start = 0;

    for (final match in _urlPattern.allMatches(widget.text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: widget.text.substring(start, match.start)));
      }

      final rawUrl = match.group(0);
      if (rawUrl != null && rawUrl.isNotEmpty) {
        spans.add(
          TextSpan(
            text: rawUrl,
            style:
                widget.linkStyle ??
                const TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _openUrl(rawUrl);
              },
          ),
        );
      }

      start = match.end;
    }

    if (start < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(start)));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: widget.text));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
          ellipsis: '…',
        )..layout(maxWidth: constraints.maxWidth);
        _overflowing = tp.didExceedMaxLines;

        if (!_overflowing || _expanded) {
          return RichText(
            text: TextSpan(
              style: widget.style,
              children: [
                ..._buildTextSpans(),
                if (_overflowing) const TextSpan(text: '  '),
                if (_overflowing)
                  TextSpan(
                    text: 'Show less',
                    style:
                        widget.linkStyle ??
                        const TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => setState(() => _expanded = false),
                  ),
              ],
            ),
          );
        }

        return RichText(
          text: TextSpan(
            style: widget.style,
            children: [
              WidgetSpan(
                child: Text(
                  widget.text,
                  maxLines: widget.trimLines,
                  overflow: TextOverflow.ellipsis,
                  style: widget.style,
                ),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: 'Show more',
                style:
                    widget.linkStyle ??
                    const TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => setState(() => _expanded = true),
              ),
            ],
          ),
        );
      },
    );
  }
}
