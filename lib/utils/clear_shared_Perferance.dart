import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

const String conversionHistoryKey = 'conversionHistory';

Future<void> clearConversionHistory() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool success = await prefs.remove(conversionHistoryKey);

    if (success) {
      developer.log(
          'Successfully cleared SharedPreferences key: $conversionHistoryKey',
          name: 'clearConversionHistory');
    } else {
      developer.log(
          'SharedPreferences key not found (already clear?): $conversionHistoryKey',
          name: 'clearConversionHistory');
    }
  } catch (e) {
    developer.log('Error clearing SharedPreferences key: $conversionHistoryKey',
        error: e, name: 'clearConversionHistory', level: 1000);
  }
}
