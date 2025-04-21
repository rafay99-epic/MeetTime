import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meettime/widgets/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryConverter extends StatefulWidget {
  const HistoryConverter({super.key});

  @override
  State<HistoryConverter> createState() => _HistoryConverterState();
}

class _HistoryConverterState extends State<HistoryConverter> {
  List<Map<String, String>> _conversionHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversionHistory();
  }

  Future<void> _loadConversionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('conversionHistory') ?? [];
      List<Map<String, String>> tempList = [];

      for (String conversionString in history) {
        List<String> parts = conversionString.split('|');
        if (parts.length == 4) {
          tempList.add({
            'sourceTime': parts[0],
            'sourceZone': parts[1],
            'targetTime': parts[2],
            'targetZone': parts[3],
          });
        }
      }

      setState(() {
        _conversionHistory = tempList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const MeetTimeAppBar(
        title: 'Conversational History',
        showBack: false,
        showSettings: false,
      ),
      backgroundColor: const Color(0xFFF5F5F5), //Consistent background color
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildConversionHistory(theme),
    );
  }

  Widget _buildConversionHistory(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'All Conversions',
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          if (_conversionHistory.isEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/img/empty.svg',
                    height: 150,
                    width: 150,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No previous conversions.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.8)),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _conversionHistory.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12), //Spacing between cards
                padding: const EdgeInsets.only(bottom: 20),
                itemBuilder: (context, index) {
                  final conversion = _conversionHistory[index];
                  return _buildHistoryCard(theme, conversion);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ThemeData theme, Map<String, String> conversion) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
            color:
                theme.colorScheme.onSurface.withOpacity(0.05)), //subtle border
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Source',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                conversion['sourceTime']!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            conversion['sourceZone']!,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                conversion['targetTime']!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            conversion['targetZone']!,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
