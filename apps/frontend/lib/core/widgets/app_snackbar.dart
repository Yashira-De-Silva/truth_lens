import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// AppSnackbar - reusable top-floating glass-style snackbar helper.
/// Usage: AppSnackbar.showError(context, 'Something went wrong');
class AppSnackbar {
  AppSnackbar._();

  static const _defaultMargin = EdgeInsets.fromLTRB(12, 12, 12, 0);

  static void _show(
    BuildContext context, {
    required String title,
    required String message,
    required Color baseColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: _defaultMargin,
          child: Align(
            alignment: Alignment.topCenter,
            child: _GlassSnack(
              title: title,
              message: message,
              baseColor: baseColor,
              onClose: () {
                try {
                  entry.remove();
                } catch (_) {}
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Auto-remove
    Timer(duration, () {
      try {
        entry.remove();
      } catch (_) {}
    });
  }

  static void showError(BuildContext context, String msg) {
    _show(
      context,
      title: 'Error',
      message: msg,
      baseColor: AppColors.error,
      duration: const Duration(seconds: 4),
    );
  }

  static void showSuccess(BuildContext context, String msg) {
    _show(
      context,
      title: 'Success',
      message: msg,
      baseColor: AppColors.success,
      duration: const Duration(seconds: 3),
    );
  }
}class _GlassSnack extends StatelessWidget {
  final String title;
  final String message;
  final Color baseColor;
  final VoidCallback? onClose;

  const _GlassSnack({
    required this.title,
    required this.message,
    required this.baseColor,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Dark glassmorphism background matching the app theme
    final bgColor = const Color(0xFF0B1220).withValues(alpha: 0.85);
    
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: baseColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      title == 'Error' ? Icons.error_outline : Icons.check_circle_outline,
                      color: baseColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 18,
                      ),
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
