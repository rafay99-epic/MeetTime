import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class TimeConversionException implements Exception {
  final String message;
  TimeConversionException(this.message);

  @override
  String toString() => 'TimeConversionException: $message';
}

class TimeConversionRepo {
  bool _isInitialized = false;
  List<String>? _cachedTimeZones;

  void initializeTimeZones() {
    if (!_isInitialized) {
      try {
        tzdata.initializeTimeZones();
        _isInitialized = true;
        _getAllTimeZonesInternal();
      } catch (e) {
        _isInitialized = false;
      }
    }
  }

  bool get isInitialized => _isInitialized;

  List<String> getAllTimeZones() {
    if (!_isInitialized) {
      throw StateError(
          'Timezone database not initialized. Call initializeTimeZones() first.');
    }
    return _cachedTimeZones ?? _getAllTimeZonesInternal();
  }

  List<String> _getAllTimeZonesInternal() {
    _cachedTimeZones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    return _cachedTimeZones!;
  }

  String convertTime({
    required DateTime sourceTime,
    required String sourceZone,
    required String targetZone,
  }) {
    if (!_isInitialized) {
      throw StateError(
          'Timezone database not initialized. Call initializeTimeZones() first.');
    }

    if (!tz.timeZoneDatabase.locations.containsKey(sourceZone)) {
      throw TimeConversionException('Invalid source timezone: $sourceZone');
    }
    if (!tz.timeZoneDatabase.locations.containsKey(targetZone)) {
      throw TimeConversionException('Invalid target timezone: $targetZone');
    }

    try {
      final sourceLocation = tz.getLocation(sourceZone);
      final targetLocation = tz.getLocation(targetZone);

      final tz.TZDateTime sourceTZTime =
          tz.TZDateTime.from(sourceTime, sourceLocation);

      final tz.TZDateTime targetTZTime =
          tz.TZDateTime.from(sourceTZTime, targetLocation);

      final String formattedTime = DateFormat('hh:mm a').format(targetTZTime);
      return formattedTime;
    } catch (e) {
      throw TimeConversionException('Error performing time conversion.');
    }
  }
}
