import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class MeetTimeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBack;
  final bool showSettings;
  final VoidCallback? onSettingsTap;

  const MeetTimeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.showBack = false,
    this.showSettings = false,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: centerTitle,
            titleSpacing: 16,
            leading: showBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            actions: [
              ...?actions,
              if (showSettings)
                IconButton(
                  icon: const Icon(LineIcons.cog, color: Colors.black87),
                  onPressed: onSettingsTap,
                ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);
}
