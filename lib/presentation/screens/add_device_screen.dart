import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/haptic_utils.dart';
import '../providers/device_provider.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _macController = TextEditingController();
  final _ipController = TextEditingController();

  late AnimationController _saveAnimController;
  late Animation<double> _saveGlowAnimation;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _saveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _saveGlowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _saveAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _macController.dispose();
    _ipController.dispose();
    _saveAnimController.dispose();
    super.dispose();
  }

  String _formatMacAddress(String value) {
    // Remove all non-hex characters
    final cleaned = value.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();

    // Insert colons every 2 characters
    final buffer = StringBuffer();
    for (var i = 0; i < cleaned.length && i < 12; i++) {
      if (i > 0 && i % 2 == 0) buffer.write(':');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  bool _isValidPartialIp(String value) {
    if (value.isEmpty) return true;
    if (!RegExp(r'^[0-9.]+$').hasMatch(value)) return false;
    if (value.startsWith('.') || value.contains('..')) return false;

    final parts = value.split('.');
    if (parts.length > 4) return false;

    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];

      // Allow trailing dot while typing (e.g. "192.")
      if (part.isEmpty) {
        if (i != parts.length - 1) return false;
        continue;
      }

      if (part.length > 3) return false;
      final number = int.tryParse(part);
      if (number == null || number > 255) return false;
    }

    return true;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Device name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateMac(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'MAC address is required';
    }
    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$');
    if (!macRegex.hasMatch(value.trim())) {
      return 'Invalid MAC format (e.g. AA:BB:CC:DD:EE:FF)';
    }
    return null;
  }

  String? _validateIp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IP address is required';
    }
    final ipRegex = RegExp(
      r'^(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$',
    );
    if (!ipRegex.hasMatch(value.trim())) {
      return 'Invalid IP format (e.g. 192.168.1.100)';
    }
    return null;
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticUtils.medium();

    try {
      await context.read<DeviceProvider>().addDevice(
        name: _nameController.text.trim(),
        macAddress: _macController.text.trim().toUpperCase(),
        ipAddress: _ipController.text.trim(),
      );

      HapticUtils.light();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save device: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Device',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Device Name
              _buildLabel('Device Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g. Gaming PC',
                icon: Icons.devices_rounded,
                validator: _validateName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              // MAC Address
              _buildLabel('MAC Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _macController,
                hint: 'e.g. AA:BB:CC:DD:EE:FF',
                icon: Icons.settings_ethernet_rounded,
                validator: _validateMac,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final formatted = _formatMacAddress(newValue.text);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }),
                ],
                maxLength: 17,
              ),
              const SizedBox(height: 24),

              // IP Address
              _buildLabel('IP Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _ipController,
                hint: 'e.g. 192.168.1.100',
                icon: Icons.language_rounded,
                validator: _validateIp,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final normalizedText = newValue.text.replaceAll(',', '.');
                    final normalizedValue = newValue.copyWith(
                      text: normalizedText,
                    );

                    if (_isValidPartialIp(normalizedText)) {
                      return normalizedValue;
                    }
                    return oldValue;
                  }),
                ],
                maxLength: 15,
              ),
              const SizedBox(height: 40),

              // Save Button
              _buildSaveButton(),
              const SizedBox(height: 24),

              // Info text
              Center(
                child: Text(
                  'Ensure your desktop has WoL enabled in BIOS\nand the network adapter settings.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textDim,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: NeuDecoration.inset(),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, color: AppColors.textDim, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.offline, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.offline, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedBuilder(
      animation: _saveGlowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _isSaving ? null : _saveDevice,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppConstants.buttonBorderRadius,
              ),
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(
                    alpha: _saveGlowAnimation.value * 0.3,
                  ),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.background,
                        ),
                      ),
                    )
                  : Text(
                      'Save Device',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
