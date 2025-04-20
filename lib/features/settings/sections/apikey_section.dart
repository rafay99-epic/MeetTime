import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meettime/config/config.dart';
import 'package:meettime/core/provider/chat_bot_provider.dart';
import 'package:meettime/widgets/appbar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class ApikeySection extends StatefulWidget {
  const ApikeySection({super.key});

  @override
  State<ApikeySection> createState() => _ApikeySectionState();
}

class _ApikeySectionState extends State<ApikeySection> {
  final _apiKeyController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  static const String _apiKeyStorageKey = SecureFolderName.secureFolderName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingKey();
  }

  Future<void> _loadExistingKey() async {
    String? storedKey;
    bool loadError = false;

    try {
      storedKey = await _storage.read(key: _apiKeyStorageKey);
    } catch (e) {
      loadError = true;
    } finally {
      if (mounted) {
        setState(() {
          if (!loadError && storedKey != null) {
            _apiKeyController.text = storedKey;
          }

          _isLoading = false;
        });

        if (loadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not load previously saved API key.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final enteredKey = _apiKeyController.text.trim();

    if (enteredKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key cannot be empty.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    try {
      await _storage.write(key: _apiKeyStorageKey, value: enteredKey);

      if (mounted) {
        Provider.of<ChatbotProvider>(context, listen: false)
            .updateApiKey(enteredKey);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Key saved securely!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save API key: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const MeetTimeAppBar(
        title: "API Key",
        showBack: true,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Manage API Key",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Enter your personal API key below to enable the chatbot features.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _apiKeyController,
                        obscureText: true,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
                          labelText: 'API Key',
                          labelStyle: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6)),
                          floatingLabelStyle:
                              TextStyle(color: theme.colorScheme.primary),
                          prefixIcon: Icon(
                            LineIcons.key,
                            color: theme.colorScheme.primary.withOpacity(0.8),
                          ),
                          filled: true,
                          fillColor:
                              theme.scaffoldBackgroundColor.withOpacity(0.5),
                          hintText: 'Paste your securely stored key here',
                          hintStyle: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.4)),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _saveApiKey,
                        child: const Text('Save API Key Securely'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
