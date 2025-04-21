import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConversionResultWidget extends StatelessWidget {
  final String convertedTime;

  const ConversionResultWidget({
    super.key,
    required this.convertedTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isError = convertedTime.toLowerCase().contains('error') ||
        convertedTime.toLowerCase().contains('please select');

    return Container(
      key: ValueKey(convertedTime),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isError
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isError ? 'Status' : 'Converted Time',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isError
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            convertedTime,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isError ? 18 : 24,
              fontWeight: isError ? FontWeight.w500 : FontWeight.w700,
              color: isError
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
