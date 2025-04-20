import 'package:flutter/material.dart';
import 'package:meettime/config/config.dart';
import 'package:meettime/core/provider/chat_bot_provider.dart';
import 'package:meettime/core/theme/theme.dart';
import 'package:meettime/features/splashscreen/splashscreen.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _apiKeyStorageKey = SecureFolderName.secureFolderName;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  String? apiKeyToUse;

  try {
    const storage = FlutterSecureStorage();
    final String? userApiKey = await storage.read(key: _apiKeyStorageKey);

    const String developerApiKey = ConfigKey.chatBotAPI;

    if (userApiKey != null && userApiKey.trim().isNotEmpty) {
      apiKeyToUse = userApiKey.trim();
    } else if (developerApiKey.trim().isNotEmpty) {
      apiKeyToUse = developerApiKey.trim();
    } else {
      apiKeyToUse = null;
    }
  } catch (e) {
    apiKeyToUse = null;
  }

  runApp(MyApp(apiKeyToUse: apiKeyToUse));
}

class MyApp extends StatelessWidget {
  final String? apiKeyToUse;

  const MyApp({super.key, required this.apiKeyToUse});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ChatbotProvider(apiKey: apiKeyToUse),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ));
  }
}
