import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meettime/features/settings/setting.dart';
import 'package:meettime/widgets/appbar.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:ui';
import 'package:timezone/timezone.dart' as tz;

class TimeConverter extends StatefulWidget {
  const TimeConverter({super.key});

  @override
  State<TimeConverter> createState() => _TimeConverterState();
}

class _TimeConverterState extends State<TimeConverter> {
  final TextEditingController _timeController = TextEditingController();
  String? _sourceZone;
  String? _targetZone;
  String? _convertedTime;

  final List<String> _timeZones = tz.timeZoneDatabase.locations.keys.toList()
    ..sort();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MeetTimeAppBar(
        title: 'Time Converter',
        showBack: false,
        showSettings: true,
        onSettingsTap: () {
          Navigator.push(
            context,
            PageTransition(
              child: const Setting(),
              childCurrent: widget,
              type: PageTransitionType.leftToRightJoined,
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTimeInput(theme),
                    const SizedBox(height: 20),
                    _buildDropdowns(theme),
                    const SizedBox(height: 30),
                    _buildConvertButton(theme),
                    const SizedBox(height: 30),
                    if (_convertedTime != null) _buildResult(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInput(ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          // ignore: use_build_context_synchronously
          final formatted = time.format(context);
          _timeController.text = formatted;
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: _timeController,
          style: GoogleFonts.poppins(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Select Time',
            labelStyle: GoogleFonts.poppins(),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.access_time),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdowns(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;

        if (isNarrow) {
          return Column(
            children: [
              _buildDropdown(
                label: 'From',
                value: _sourceZone,
                onChanged: (val) => setState(() => _sourceZone = val),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'To',
                value: _targetZone,
                onChanged: (val) => setState(() => _targetZone = val),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'From',
                  value: _sourceZone,
                  onChanged: (val) => setState(() => _sourceZone = val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'To',
                  value: _targetZone,
                  onChanged: (val) => setState(() => _targetZone = val),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      menuMaxHeight: 300,
      items: _timeZones
          .map((zone) => DropdownMenuItem(
                value: zone,
                child: Text(
                  zone,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      icon: const Icon(Icons.keyboard_arrow_down),
      dropdownColor: Colors.white,
    );
  }

  Widget _buildConvertButton(ThemeData theme) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(fontSize: 16),
      ),
      onPressed: _convertTime,
      child: const Text('Convert'),
    );
  }

  Widget _buildResult(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Converted Time:\n$_convertedTime',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  void _convertTime() {
    if (_timeController.text.isEmpty ||
        _sourceZone == null ||
        _targetZone == null) {
      setState(() => _convertedTime = 'Please select all fields.');
      return;
    }

    try {
      final sourceLocation = tz.getLocation(_sourceZone!);
      final targetLocation = tz.getLocation(_targetZone!);

      final timeParts = _timeController.text.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1].split(' ')[0]);
      final isPM = _timeController.text.toLowerCase().contains('pm');
      final adjustedHour = (isPM && hour < 12) ? hour + 12 : hour;

      final now = DateTime.now();
      final localTime = tz.TZDateTime(
        sourceLocation,
        now.year,
        now.month,
        now.day,
        adjustedHour,
        minute,
      );

      final converted = tz.TZDateTime.from(localTime, targetLocation);

      final timeOfDay =
          TimeOfDay(hour: converted.hour, minute: converted.minute);

      setState(() {
        _convertedTime = timeOfDay.format(context);
      });
    } catch (e) {
      setState(() {
        _convertedTime = 'Error during conversion: ${e.toString()}';
      });
    }
  }
}
