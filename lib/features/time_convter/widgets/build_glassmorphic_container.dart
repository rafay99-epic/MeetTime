import 'dart:ui';

import 'package:flutter/material.dart';

Widget buildGlassmorphicContainer(ThemeData theme, Widget child) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(32),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.75),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}
