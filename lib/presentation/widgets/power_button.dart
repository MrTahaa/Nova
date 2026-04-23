import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/haptic_utils.dart';

enum PowerButtonState { idle, waking, online }

class PowerButton extends StatefulWidget {
  final PowerButtonState state;
  final VoidCallback onPressed;
  final double size;

  const PowerButton({
    super.key,
    required this.state,
    required this.onPressed,
    this.size = AppConstants.powerButtonSize,
  });

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tapController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _tapScaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: AppConstants.animPulse,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _tapController = AnimationController(
      vsync: this,
      duration: AppConstants.animFast,
    );
    _tapScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(PowerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulse();
  }

  void _updatePulse() {
    if (widget.state == PowerButtonState.waking) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  Color get _buttonColor {
    switch (widget.state) {
      case PowerButtonState.online:
        return AppColors.online;
      case PowerButtonState.waking:
        return AppColors.accent;
      case PowerButtonState.idle:
        return AppColors.textDim;
    }
  }

  Color get _glowColor {
    switch (widget.state) {
      case PowerButtonState.online:
        return AppColors.online;
      case PowerButtonState.waking:
        return AppColors.accent;
      case PowerButtonState.idle:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    _updatePulse();

    return GestureDetector(
      onTapDown: (_) {
        _tapController.forward();
        HapticUtils.medium();
      },
      onTapUp: (_) {
        _tapController.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        _tapController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _tapScaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _tapScaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: _buttonColor.withValues(
                    alpha: 0.3 + (0.4 * _pulseAnimation.value),
                  ),
                  width: 2,
                ),
                boxShadow: [
                  // Base neumorphic shadow
                  const BoxShadow(
                    color: AppColors.neuShadowDark,
                    offset: Offset(4, 4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: AppColors.neuShadowLight.withValues(alpha: 0.3),
                    offset: const Offset(-3, -3),
                    blurRadius: 8,
                  ),
                  // Glow
                  if (widget.state != PowerButtonState.idle)
                    BoxShadow(
                      color: _glowColor.withValues(
                        alpha: 0.15 + (0.25 * _pulseAnimation.value),
                      ),
                      blurRadius: 20 + (15 * _pulseAnimation.value),
                      spreadRadius: 2 + (6 * _pulseAnimation.value),
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Spinning ring for waking state
                  if (widget.state == PowerButtonState.waking)
                    SizedBox(
                      width: widget.size - 8,
                      height: widget.size - 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _glowColor.withValues(
                            alpha: 0.3 + (0.4 * _pulseAnimation.value),
                          ),
                        ),
                      ),
                    ),
                  // Power icon
                  Icon(
                    Icons.power_settings_new_rounded,
                    size: widget.size * 0.45,
                    color: _buttonColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// An animated background ring used behind the power button for emphasis.
class PowerButtonRing extends StatefulWidget {
  final bool active;
  final Color color;
  final double size;

  const PowerButtonRing({
    super.key,
    required this.active,
    required this.color,
    this.size = 80,
  });

  @override
  State<PowerButtonRing> createState() => _PowerButtonRingState();
}

class _PowerButtonRingState extends State<PowerButtonRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(PowerButtonRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.transparent,
                width: 2,
              ),
              gradient: SweepGradient(
                colors: [
                  widget.color.withValues(alpha: 0.0),
                  widget.color.withValues(alpha: 0.3),
                  widget.color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
