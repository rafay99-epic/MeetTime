import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeInputWidget extends StatelessWidget {
  final String selectedTimeText;
  final VoidCallback onTap;

  const TimeInputWidget({
    super.key,
    required this.selectedTimeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: IgnorePointer(
        child: TextField(
          controller: TextEditingController(text: selectedTimeText),
          readOnly: true,
          style: GoogleFonts.poppins(
              fontSize: 16, color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Select Time',
            labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.access_time_rounded,
                color: theme.colorScheme.primary),
            hintText: selectedTimeText.isEmpty ? 'Tap to select' : null,
            hintStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }
}
