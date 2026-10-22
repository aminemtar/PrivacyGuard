import 'package:flutter/material.dart';

/// Covers app content when the detection engine requests protection.
///
/// This widget only covers the Flutter subtree where it is installed. It
/// cannot cover other apps or change the physical display's viewing angle.
class PrivacyOverlay extends StatelessWidget {
  const PrivacyOverlay({
    required this.protect,
    required this.child,
    this.message = 'Privacy protection active',
    super.key,
  });

  final bool protect;
  final Widget child;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (protect)
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0xF5071426),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3678F6).withValues(alpha: .16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF55D6E8).withValues(alpha: .6),
                          ),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Color(0xFF55D6E8),
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your content is temporarily hidden.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
