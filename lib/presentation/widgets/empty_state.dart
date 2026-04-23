import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyState extends StatefulWidget {
  final VoidCallback onAddDevice;

  const EmptyState({super.key, required this.onAddDevice});

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.devices_rounded,
                size: 56,
                color: AppColors.accent.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No devices yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first device to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textDim,
                  ),
            ),
            const SizedBox(height: 32),
            // Add device button
            GestureDetector(
              onTap: widget.onAddDevice,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppColors.accentGradient,
                  boxShadow: NeuDecoration.glowShadow(
                    AppColors.accent,
                    intensity: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: AppColors.background,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Device',
                      style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.w700,
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
