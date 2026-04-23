import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class NovaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? subtitle;
  final List<Widget>? actions;

  const NovaAppBar({
    super.key,
    this.subtitle,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            // Logo & title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accent, Color(0xFF80FFF0)],
                  ).createShader(bounds),
                  child: Text(
                    'Nova',
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textDim,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                  ),
              ],
            ),
            const Spacer(),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
