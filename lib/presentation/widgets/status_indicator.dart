import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatusIndicator extends StatefulWidget {
  final bool isOnline;
  final bool isPinging;
  final bool isWaking;
  final double size;

  const StatusIndicator({
    super.key,
    this.isOnline = false,
    this.isPinging = false,
    this.isWaking = false,
    this.size = 10,
  });

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.isPinging || widget.isWaking) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (widget.isWaking) return AppColors.waking;
    if (widget.isPinging) return AppColors.textDim;
    if (widget.isOnline) return AppColors.online;
    return AppColors.offline;
  }

  @override
  Widget build(BuildContext context) {
    _updateAnimation();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _statusColor.withValues(alpha: _pulseAnimation.value),
            boxShadow: [
              BoxShadow(
                color: _statusColor.withValues(
                  alpha: 0.4 * _pulseAnimation.value,
                ),
                blurRadius: 8,
                spreadRadius: 2 * _pulseAnimation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
