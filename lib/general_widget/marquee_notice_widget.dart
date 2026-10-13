import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class MarqueeNoticeWidget extends StatefulWidget {
  final String text;

  const MarqueeNoticeWidget({
    super.key,
    required this.text,
  });

  @override
  State<MarqueeNoticeWidget> createState() => _MarqueeNoticeWidgetState();
}

class _MarqueeNoticeWidgetState extends State<MarqueeNoticeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Continuous infinite marquee ticker
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _callNoticeNumber() {
    final match = RegExp(r'01\d{9}').firstMatch(widget.text);
    if (match != null) {
      final phone = match.group(0)!;
      final uri = Uri(scheme: 'tel', path: phone);
      try {
        if (kIsWeb) {
          launchUrl(uri, webOnlyWindowName: '_self');
        } else {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        try {
          launchUrl(uri);
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _callNoticeNumber,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.noticeRed, // Bright red matching screenshot
          borderRadius: BorderRadius.circular(8), // Exact 8px radius
        ),
        child: Row(
        children: [
          // Fixed Dark Red NOTICE Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              color: AppColors.noticeBadgeRed, // Dark burgundy red
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'NOTICE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Continuous Marquee Notice Text
          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final dx = (1.0 - _controller.value) * (width + 350) - 350;
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: OverflowBox(
                          minWidth: 0.0,
                          maxWidth: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

