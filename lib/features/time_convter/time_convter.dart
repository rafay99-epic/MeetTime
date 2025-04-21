import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meettime/core/repositories/time_conversion_repo.dart';
import 'package:meettime/features/time_convter/widgets/timezone_bottom_sheet.dart';
import 'package:meettime/features/time_convter/widgets/timezone_selection_widget';
import 'package:meettime/utils/shared_perference_time_conver.dart';
import 'package:meettime/widgets/appbar.dart';
import 'widgets/time_input_widget.dart';
import 'widgets/conversion_result_widget.dart';

class TimeConverterScreen extends StatefulWidget {
  const TimeConverterScreen({super.key});

  @override
  State<TimeConverterScreen> createState() => _TimeConverterScreenState();
}

class _TimeConverterScreenState extends State<TimeConverterScreen> {
  final _repo = TimeConversionRepo();

  String? _sourceZone;
  String? _targetZone;
  String? _convertedTime;
  DateTime? _selectedTime;
  String _selectedTimeText = '';
  bool _isLoadingTimezones = true;

  @override
  void initState() {
    super.initState();
    _initializeTimeZones();
  }

  void _initializeTimeZones() async {
    try {
      _repo.initializeTimeZones();
    } catch (_) {
      _showSnackBar('Failed to load timezone data.');
    } finally {
      setState(() => _isLoadingTimezones = !_repo.isInitialized);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: Column(
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
                    onSelectSource: () => _openZonePicker(isSource: true),
                    onSelectTarget: () => _openZonePicker(isSource: false),
                  ),
                  const SizedBox(height: 30),
                  _buildConvertButton(theme),
                  const SizedBox(height: 30),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _convertedTime != null
                        ? ConversionResultWidget(convertedTime: _convertedTime!)
                        : const SizedBox(height: 60),
                  ),
                ],
              ),
            ),
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
      onPressed: _isLoadingTimezones || !_canConvert() ? null : _convertTime,
      child: _isLoadingTimezones
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Text('Convert Time'),
    );
  }

  bool _canConvert() {
    return _selectedTime != null && _sourceZone != null && _targetZone != null;
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime != null
          ? TimeOfDay.fromDateTime(_selectedTime!)
          : TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final now = DateTime.now();
      final newTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      setState(() {
        _selectedTime = newTime;
        _selectedTimeText = DateFormat('hh:mm a').format(newTime);
        _convertedTime = null;
      });
    }
  }

  void _openZonePicker({required bool isSource}) {
    if (_isLoadingTimezones || !_repo.isInitialized) {
      _showSnackBar('Timezones are still loading or failed to load.');
      return;
    }

    final zones = _repo.getAllTimeZones();

    if (zones.isEmpty) {
      _showSnackBar('No timezones found.');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TimeZoneBottomSheet(
        timeZones: zones,
        onTimeZoneSelected: (zone) {
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
      ),
    );
  }

  Future<void> _convertTime() async {
    try {
      final result = _repo.convertTime(
        sourceTime: _selectedTime!,
        sourceZone: _sourceZone!,
        targetZone: _targetZone!,
      );

      final formattedSource = DateFormat('hh:mm a').format(_selectedTime!);

      setState(() {
        _convertedTime = result;
      });

      await saveConversionToHistory(
        formattedSource,
        _sourceZone!,
        result,
        _targetZone!,
      );
    } on TimeConversionException catch (e) {
      _handleError('Conversion Error: ${e.message}');
    } catch (e) {
      _handleError('Unexpected error: $e');
    }
  }

  void _handleError(String msg) {
    setState(() {
      _convertedTime = msg;
    });
    _showSnackBar(msg);
  }
}
