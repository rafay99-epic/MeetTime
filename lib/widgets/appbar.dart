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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              16, 16, 16, 12), // Increased vertical padding
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  icon: Icon(LineIcons.arrowLeft,
                      color: theme.colorScheme.onPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 24,
                ),
              Expanded(
                child: Text(
                  title,
                  textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              if (showSettings)
                IconButton(
                  icon: Icon(LineIcons.cog, color: theme.colorScheme.onPrimary),
                  onPressed: onSettingsTap,
                  splashRadius: 24,
                ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}
