import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meettime/widgets/appbar.dart';
import 'dart:ui';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  DateTime? _selectedTime;
  final List<String> _allTimeZones = tz.timeZoneDatabase.locations.keys.toList()
    ..sort();

  List<String> _filteredSourceTimeZones = [];
  List<String> _filteredTargetTimeZones = [];

  final TextEditingController _sourceSearchController = TextEditingController();
  final TextEditingController _targetSearchController = TextEditingController();

  bool _isSourceDropdownOpen = false;
  bool _isTargetDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredSourceTimeZones = List.from(_allTimeZones);
    _filteredTargetTimeZones = List.from(_allTimeZones);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (_isSourceDropdownOpen) {
          setState(() => _isSourceDropdownOpen = false);
        }
        if (_isTargetDropdownOpen) {
          setState(() => _isTargetDropdownOpen = false);
        }
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
              const SizedBox(height: 20),
              _buildGlassmorphicContainer(
                theme,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTimeInput(theme),
                    const SizedBox(height: 24),
                    _buildDropdowns(theme),
                    const SizedBox(height: 30),
                    _buildConvertButton(theme),
                    const SizedBox(height: 30),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _convertedTime != null
                          ? _buildResult(theme)
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContainer(ThemeData theme, Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTimeInput(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
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
            _selectedTime = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              time.hour,
              time.minute,
            );
            _timeController.text = DateFormat('hh:mm a').format(_selectedTime!);
          });
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: IgnorePointer(
        child: TextField(
          controller: _timeController,
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
            suffixIcon: Icon(Icons.edit_calendar_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.7)),
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
              _buildSearchableDropdown(
                theme: theme,
                label: 'From Timezone',
                value: _sourceZone,
                onChanged: (val) => setState(() => _sourceZone = val),
                searchController: _sourceSearchController,
                filteredTimeZones: _filteredSourceTimeZones,
                onSearchChanged: (text) {
                  _filterTimeZones(text, isSource: true);
                },
                isDropdownOpen: _isSourceDropdownOpen,
                onDropdownToggle: (isOpen) =>
                    setState(() => _isSourceDropdownOpen = isOpen),
              ),
              const SizedBox(height: 16),
              _buildSearchableDropdown(
                theme: theme,
                label: 'To Timezone',
                value: _targetZone,
                onChanged: (val) => setState(() => _targetZone = val),
                searchController: _targetSearchController,
                filteredTimeZones: _filteredTargetTimeZones,
                onSearchChanged: (text) {
                  _filterTimeZones(text, isSource: false);
                },
                isDropdownOpen: _isTargetDropdownOpen,
                onDropdownToggle: (isOpen) =>
                    setState(() => _isTargetDropdownOpen = isOpen),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: _buildSearchableDropdown(
                  theme: theme,
                  label: 'From Timezone',
                  value: _sourceZone,
                  onChanged: (val) => setState(() => _sourceZone = val),
                  searchController: _sourceSearchController,
                  filteredTimeZones: _filteredSourceTimeZones,
                  onSearchChanged: (text) {
                    _filterTimeZones(text, isSource: true);
                  },
                  isDropdownOpen: _isSourceDropdownOpen,
                  onDropdownToggle: (isOpen) =>
                      setState(() => _isSourceDropdownOpen = isOpen),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSearchableDropdown(
                  theme: theme,
                  label: 'To Timezone',
                  value: _targetZone,
                  onChanged: (val) => setState(() => _targetZone = val),
                  searchController: _targetSearchController,
                  filteredTimeZones: _filteredTargetTimeZones,
                  onSearchChanged: (text) {
                    _filterTimeZones(text, isSource: false);
                  },
                  isDropdownOpen: _isTargetDropdownOpen,
                  onDropdownToggle: (isOpen) =>
                      setState(() => _isTargetDropdownOpen = isOpen),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSearchableDropdown({
    required ThemeData theme,
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required TextEditingController searchController,
    required List<String> filteredTimeZones,
    required ValueChanged<String> onSearchChanged,
    required bool isDropdownOpen,
    required ValueChanged<bool> onDropdownToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FocusScope(
          child: Focus(
            onFocusChange: (focus) {
              if (focus) {
                onDropdownToggle(true);
              } else {
                onDropdownToggle(false);
              }
            },
            child: TextFormField(
              controller: searchController,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.7)),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Icon(Icons.search,
                    color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              onChanged: onSearchChanged,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (isDropdownOpen)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredTimeZones.length,
              itemBuilder: (context, index) {
                final zone = filteredTimeZones[index];
                return InkWell(
                  onTap: () {
                    onChanged(zone);
                    searchController.text = zone;
                    if (searchController == _sourceSearchController) {
                      _filterTimeZones('', isSource: true);
                    } else {
                      _filterTimeZones('', isSource: false);
                    }
                    FocusScope.of(context).unfocus();
                    onDropdownToggle(false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      zone,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: theme.colorScheme.onSurface),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _filterTimeZones(String query, {required bool isSource}) {
    List<String> filteredList = _allTimeZones
        .where((zone) => zone.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      if (isSource) {
        _filteredSourceTimeZones = filteredList;
      } else {
        _filteredTargetTimeZones = filteredList;
      }
    });
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
      onPressed: _convertTime,
      child: const Text('Convert Time'),
    );
  }

  Widget _buildResult(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
            'Converted Time',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _convertedTime!,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _convertTime() async {
    if (_timeController.text.isEmpty ||
        _sourceZone == null ||
        _targetZone == null) {
      setState(() => _convertedTime = 'Please select all fields.');
      return;
    }

    try {
      if (_selectedTime == null) {
        setState(() {
          _convertedTime = 'Invalid Time Selected';
        });
        return;
      }
      final sourceLocation = tz.getLocation(_sourceZone!);
      final targetLocation = tz.getLocation(_targetZone!);

      final tz.TZDateTime sourceTime = tz.TZDateTime(
          sourceLocation,
          _selectedTime!.year,
          _selectedTime!.month,
          _selectedTime!.day,
          _selectedTime!.hour,
          _selectedTime!.minute);

      final tz.TZDateTime convertedTime =
          tz.TZDateTime.from(sourceTime, targetLocation);

      final String formattedTime = DateFormat('hh:mm a').format(convertedTime);

      setState(() {
        _convertedTime = formattedTime;
      });

      await _saveConversionToHistory(
        DateFormat('hh:mm a').format(_selectedTime!),
        _sourceZone!,
        formattedTime,
        _targetZone!,
      );
    } catch (e) {
      setState(() {
        _convertedTime = 'Error during conversion: ${e.toString()}';
      });
    }
  }

  Future<void> _saveConversionToHistory(String sourceTime, String sourceZone,
      String targetTime, String targetZone) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('conversionHistory') ?? [];

    String conversionString = '$sourceTime|$sourceZone|$targetTime|$targetZone';
    history.insert(0, conversionString);

    await prefs.setStringList('conversionHistory', history);
  }
}
