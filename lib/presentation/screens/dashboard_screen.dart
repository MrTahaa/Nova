import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/device_provider.dart';
import '../widgets/device_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/nova_app_bar.dart';
import 'add_device_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().loadDevices();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<DeviceProvider>().pingAllDevices();
  }

  void _navigateToAddDevice() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddDeviceScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: AppConstants.animMedium,
        reverseTransitionDuration: AppConstants.animFast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NovaAppBar(
        subtitle: 'WAKE ON LAN',
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, provider, _) {
          if (provider.devices.isEmpty) {
            return EmptyState(onAddDevice: _navigateToAddDevice);
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePadding,
                vertical: 8,
              ),
              itemCount: provider.devices.length,
              itemBuilder: (context, index) {
                final device = provider.devices[index];
                return DeviceCard(
                  key: ValueKey(device.id),
                  device: device,
                  index: index,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<DeviceProvider>(
        builder: (context, provider, _) {
          if (provider.devices.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: _navigateToAddDevice,
            child: const Icon(Icons.add_rounded, size: 28),
          );
        },
      ),
    );
  }
}
