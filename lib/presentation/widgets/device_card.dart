import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/haptic_utils.dart';
import '../../data/models/device_model.dart';
import '../providers/device_provider.dart';
import 'power_button.dart';
import 'status_indicator.dart';

class DeviceCard extends StatefulWidget {
  final DeviceModel device;
  final int index;

  const DeviceCard({
    super.key,
    required this.device,
    required this.index,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: AppConstants.animEntrance,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );

    // Stagger entrance based on index
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  IconData _getDeviceIcon() {
    switch (widget.device.icon) {
      case 'laptop':
        return Icons.laptop_mac_rounded;
      case 'server':
        return Icons.dns_rounded;
      case 'gaming':
        return Icons.sports_esports_rounded;
      default:
        return Icons.desktop_windows_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, provider, _) {
        final status = provider.getDeviceStatus(widget.device.id);
        final isWaking = status == DeviceStatus.waking;
        final isOnline = status == DeviceStatus.online;
        final isPinging = status == DeviceStatus.pinging;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Dismissible(
              key: Key(widget.device.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                HapticUtils.medium();
                provider.deleteDevice(widget.device.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.device.name} removed'),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: AppColors.accent,
                      onPressed: () {
                        provider.addDevice(
                          name: widget.device.name,
                          macAddress: widget.device.macAddress,
                          ipAddress: widget.device.ipAddress,
                          icon: widget.device.icon,
                        );
                      },
                    ),
                  ),
                );
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppConstants.cardBorderRadius),
                  gradient: const LinearGradient(
                    colors: [Colors.transparent, Color(0x33FF5252)],
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.offline,
                  size: 28,
                ),
              ),
              child: AnimatedContainer(
                duration: AppConstants.animMedium,
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(AppConstants.cardPadding),
                transform: Matrix4.translationValues(
                  0,
                  isWaking ? -4 : 0,
                  0,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppConstants.cardBorderRadius),
                  gradient: AppColors.cardGradient,
                  border: Border.all(
                    color: isWaking
                        ? AppColors.accent.withValues(alpha: 0.2)
                        : isOnline
                            ? AppColors.online.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.03),
                    width: 1,
                  ),
                  boxShadow: [
                    // Base neumorphic shadows
                    BoxShadow(
                      color: AppColors.neuShadowDark
                          .withValues(alpha: isWaking ? 0.9 : 0.7),
                      offset: Offset(6, isWaking ? 10 : 6),
                      blurRadius: isWaking ? 24 : 16,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: AppColors.neuShadowLight.withValues(alpha: 0.4),
                      offset: const Offset(-4, -4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                    // Glow when waking
                    if (isWaking)
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    // Subtle glow when online
                    if (isOnline)
                      BoxShadow(
                        color: AppColors.online.withValues(alpha: 0.06),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    // Device icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: AppColors.background.withValues(alpha: 0.6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getDeviceIcon(),
                        color: isOnline
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Device info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.device.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusIndicator(
                                isOnline: isOnline,
                                isPinging: isPinging,
                                isWaking: isWaking,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.device.macAddress,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      letterSpacing: 1.2,
                                    ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.device.ipAddress,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textDim,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Power button
                    PowerButton(
                      state: isWaking
                          ? PowerButtonState.waking
                          : isOnline
                              ? PowerButtonState.online
                              : PowerButtonState.idle,
                      onPressed: () {
                        HapticUtils.heavy();
                        provider.wakeDevice(widget.device.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
