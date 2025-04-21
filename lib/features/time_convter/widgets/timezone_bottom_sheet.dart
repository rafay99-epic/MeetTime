import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeZoneBottomSheet extends StatefulWidget {
  final List<String> timeZones;
  final ValueChanged<String> onTimeZoneSelected;
  final ThemeData theme;

  const TimeZoneBottomSheet({
    super.key,
    required this.timeZones,
    required this.onTimeZoneSelected,
    required this.theme,
  });

  @override
  TimeZoneBottomSheetState createState() => TimeZoneBottomSheetState();
}

class TimeZoneBottomSheetState extends State<TimeZoneBottomSheet> {
  String searchQuery = '';
  List<String> _filteredTimeZones = [];

  @override
  void initState() {
    super.initState();
    _filteredTimeZones = List.from(widget.timeZones);
  }

  void _filterTimeZones(String query) {
    setState(() {
      searchQuery = query;
      _filteredTimeZones = widget.timeZones
          .where((zone) => zone.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              style: GoogleFonts.poppins(
                  fontSize: 16, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Search Timezone',
                labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search,
                    color: theme.colorScheme.onSurface.withOpacity(0.5)),
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterTimeZones,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Scrollbar(
                  radius: const Radius.circular(12),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _filteredTimeZones.length,
                    itemBuilder: (context, index) {
                      final zone = _filteredTimeZones[index];
                      return InkWell(
                        onTap: () {
                          widget.onTimeZoneSelected(zone);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: searchQuery.isNotEmpty &&
                                    zone
                                        .toLowerCase()
                                        .contains(searchQuery.toLowerCase())
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Text(
                            zone,
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
