import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveConversionToHistory(String sourceTime, String sourceZone,
    String targetTime, String targetZone) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> history = prefs.getStringList('conversionHistory') ?? [];

  String conversionString = '$sourceTime|$sourceZone|$targetTime|$targetZone';
  history.insert(0, conversionString);

  await prefs.setStringList(
    'conversionHistory',
    history,
  );
}
