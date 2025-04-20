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
  final Widget? leading;

  const MeetTimeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.showBack = false,
    this.showSettings = false,
    this.onSettingsTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 12),
          child: Row(
            children: [
              if (leading != null)
                leading!
              else if (showBack)
                IconButton(
                  icon: Icon(LineIcons.arrowLeft,
                      color: theme.colorScheme.onPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 24,
                ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Hero(
                    tag: 'appbar-title',
                    child: Text(
                      title,
                      textAlign:
                          centerTitle ? TextAlign.center : TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              if (showSettings)
                IconButton(
                  icon: Icon(LineIcons.cog, color: theme.colorScheme.onPrimary),
                  onPressed: onSettingsTap,
                  splashRadius: 24,
                ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}
