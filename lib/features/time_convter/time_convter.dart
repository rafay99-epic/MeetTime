import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meettime/features/time_convter/widgets/build_glassmorphic_container.dart';
import 'package:meettime/features/time_convter/widgets/timezone_bottom_sheet.dart';
import 'package:meettime/features/time_convter/widgets/timezone_selection_widget';
import 'package:meettime/utils/shared_perference_time_conver.dart';
import 'package:meettime/widgets/appbar.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'widgets/time_input_widget.dart';
import 'widgets/conversion_result_widget.dart';

class TimeConverterScreen extends StatefulWidget {
  const TimeConverterScreen({super.key});

  @override
  State<TimeConverterScreen> createState() => _TimeConverterScreenState();
}

class _TimeConverterScreenState extends State<TimeConverterScreen> {
  String? _sourceZone;
  String? _targetZone;
  String? _convertedTime;
  DateTime? _selectedTime;
  String _selectedTimeText = '';
  List<String> _allTimeZones = [];

  @override
  void initState() {
    super.initState();
    _initializeTimeZones();
  }

  void _initializeTimeZones() {
    tzdata.initializeTimeZones();
    setState(() {
      _allTimeZones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const MeetTimeAppBar(
        title: 'Time Converter',
        showBack: false,
        showSettings: false,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            buildGlassmorphicContainer(
              theme,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TimeInputWidget(
                    selectedTimeText: _selectedTimeText,
                    onTap: _selectTime,
                  ),
                  const SizedBox(height: 24),
                  TimeZoneSelectionWidget(
                    sourceZone: _sourceZone,
                    targetZone: _targetZone,
                    onSelectSource: () =>
                        _showTimeZoneBottomSheet(context, isSource: true),
                    onSelectTarget: () =>
                        _showTimeZoneBottomSheet(context, isSource: false),
                  ),
                  const SizedBox(height: 30),
                  _buildConvertButton(theme),
                  const SizedBox(height: 30),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _convertedTime != null
                        ? ConversionResultWidget(convertedTime: _convertedTime!)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildConvertButton(ThemeData theme) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shadowColor: Colors.black26,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle:
            GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onPressed: _canConvert() ? _convertTime : null,
      child: const Text('Convert Time'),
    );
  }

  bool _canConvert() {
    return _selectedTime != null && _sourceZone != null && _targetZone != null;
  }

  Future<void> _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime != null
          ? TimeOfDay.fromDateTime(_selectedTime!)
          : TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        final theme = Theme.of(context);
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.colorScheme.primary,
            ),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        final now = DateTime.now();
        _selectedTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        _selectedTimeText = DateFormat('hh:mm a').format(_selectedTime!);
        _convertedTime = null;
      });
    }
  }

  void _showTimeZoneBottomSheet(BuildContext context,
      {required bool isSource}) {
    if (_allTimeZones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading timezones... Please wait.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return TimeZoneBottomSheet(
          timeZones: _allTimeZones,
          onTimeZoneSelected: (String zone) {
            setState(() {
              if (isSource) {
                _sourceZone = zone;
              } else {
                _targetZone = zone;
              }
              _convertedTime = null;
            });
            Navigator.pop(context);
          },
          theme: Theme.of(context),
        );
      },
    );
  }

  void _convertTime() async {
    if (!_canConvert()) {
      setState(() => _convertedTime = 'Please select time and timezones.');
      return;
    }

    if (_allTimeZones.isEmpty) {
      setState(() => _convertedTime = 'Timezone data not ready.');
      return;
    }

    try {
      if (!tz.timeZoneDatabase.locations.containsKey(_sourceZone!) ||
          !tz.timeZoneDatabase.locations.containsKey(_targetZone!)) {
        setState(() => _convertedTime = 'Invalid timezone selected.');
        return;
      }

      final sourceLocation = tz.getLocation(_sourceZone!);
      final targetLocation = tz.getLocation(_targetZone!);

      final tz.TZDateTime sourceTime =
          tz.TZDateTime.from(_selectedTime!, sourceLocation);

      final tz.TZDateTime targetTime =
          tz.TZDateTime.from(sourceTime, targetLocation);

      final String formattedTime = DateFormat('hh:mm a').format(targetTime);
      final String formattedSourceTime =
          DateFormat('hh:mm a').format(_selectedTime!);

      setState(() {
        _convertedTime = formattedTime;
      });

      await saveConversionToHistory(
        formattedSourceTime,
        _sourceZone!,
        formattedTime,
        _targetZone!,
      );
    } catch (e) {
      setState(() {
        _convertedTime = 'Error during conversion.';
      });
    }
  }
}
