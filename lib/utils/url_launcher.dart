import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

Future<bool> redirectToUrl(String urlString, {BuildContext? context}) async {
  if (urlString.isEmpty) {
    const message = 'Cannot open an empty URL.';
    developer.log(message, name: 'redirectToUrl');
    _showErrorSnackbar(context, message);
    return false;
  }

  Uri? uri;
  try {
    uri = Uri.parse(urlString);
  } catch (e) {
    final message = 'Invalid URL format: $urlString';
    developer.log(message, error: e, name: 'redirectToUrl');
    _showErrorSnackbar(context, message);
    return false;
  }

  if (await canLaunchUrl(uri)) {
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        final message = 'Could not launch URL: $urlString';
        developer.log(message, name: 'redirectToUrl');
        _showErrorSnackbar(context, message);
        return false;
      }
      developer.log('Successfully initiated launch for URL: $urlString',
          name: 'redirectToUrl');
      return true;
    } catch (e) {
      const message = 'An error occurred while trying to open the URL.';
      developer.log(message, error: e, name: 'redirectToUrl');
      _showErrorSnackbar(context, message);
      return false;
    }
  } else {
    final message = 'Device cannot handle this type of URL: $urlString';
    developer.log(message, name: 'redirectToUrl');
    _showErrorSnackbar(context, message);
    return false;
  }
}

void _showErrorSnackbar(BuildContext? context, String message) {
  if (context != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
