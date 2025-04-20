import 'package:flutter/material.dart';
import 'package:flutter_app_info/package_info_plus.dart';
import 'package:line_icons/line_icons.dart';
import 'package:meettime/features/settings/sections/apikey_section.dart';
import 'package:meettime/utils/clear_shared_Perferance.dart';
import 'package:meettime/utils/url_launcher.dart';
import 'package:meettime/widgets/appbar.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String appName = 'Loading...';
  String _version = 'Loading...';
  String buildNumber = 'Loading...';
  bool _isLoadingInfo = true;

  static const String _privacyPolicyUrl = "https://your-website.com/privacy";
  static const String _termsUrl = "https://your-website.com/terms";
  static const String _contactEmail = "99marafay@gmail.com";

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          appName = info.appName;
          _version = info.version;
          buildNumber = info.buildNumber;
          _isLoadingInfo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          appName = 'Error';
          _version = 'Error';
          buildNumber = 'Error';
          _isLoadingInfo = false;
        });
      }
    }
  }

  Future<void> handleClearHistoryTap() async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          icon: Icon(
            LineIcons.exclamationTriangle,
            color: theme.colorScheme.error,
            size: 40,
          ),
          iconPadding: const EdgeInsets.only(top: 20.0, bottom: 0),
          title: Text(
            'Confirm Action',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
              'Are you sure you want to clear all conversion history? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              )),
          actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              child: const Text('Clear History'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await clearConversionHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conversion history cleared.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing history: $e')),
          );
        }
      }
    }
  }

  void _navigateToAppInfoPage() {
    if (_isLoadingInfo) return;
  }

  void _handlePrivacyPolicyTap() async {
    await redirectToUrl(_privacyPolicyUrl, context: context);
  }

  void _handleTermsTap() async {
    await redirectToUrl(_termsUrl, context: context);
  }

  void _handleContactTap() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      queryParameters: {
        'subject': 'MeetTime App Support',
      },
    );
    await redirectToUrl(emailLaunchUri.toString(), context: context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const MeetTimeAppBar(
        title: 'Settings',
        showBack: false,
        showSettings: false,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        children: <Widget>[
          _buildSettingsHeader(context, 'Common Settings'),
          _buildSettingItem(
            context: context,
            icon: LineIcons.robot,
            title: 'ChatBot API Key',
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApikeySection(),
                ),
              )
            },
          ),
          _buildSettingsHeader(context, 'Data Management'),
          _buildSettingItem(
            context: context,
            icon: LineIcons.trash,
            title: 'Clear Conversion History',
            onPressed: handleClearHistoryTap,
            iconColor: theme.colorScheme.error,
          ),
          const Divider(height: 20, indent: 16, endIndent: 16),
          _buildSettingsHeader(context, 'About'),
          _buildSettingItem(
            context: context,
            icon: LineIcons.infoCircle,
            title: 'App Info',
            trailing: _isLoadingInfo
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_version,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.secondary)),
            onPressed: _navigateToAppInfoPage,
          ),
          const Divider(height: 20, indent: 16, endIndent: 16),
          _buildSettingsHeader(context, 'Legal & Support'),
          _buildSettingItem(
            context: context,
            title: 'Privacy Policy',
            icon: LineIcons.plus,
            onPressed: _handlePrivacyPolicyTap,
          ),
          _buildSettingItem(
            context: context,
            title: 'Terms and Conditions',
            icon: LineIcons.fileContract,
            onPressed: _handleTermsTap,
          ),
          _buildSettingItem(
            context: context,
            title: 'Contact Us',
            subtitle: "Email Us at $_contactEmail",
            icon: LineIcons.envelope,
            onPressed: _handleContactTap,
          ),
          const Divider(height: 20, indent: 16, endIndent: 16),
          _buildSettingsHeader(context, 'Diagnostics'),
          _buildSettingItem(
            context: context,
            icon: LineIcons.codeBranch,
            title: 'Environment',
            trailing: Text(
              'Production',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            onPressed: null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback? onPressed,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    bool isTappable = onPressed != null;

    return Material(
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16.0, vertical: subtitle != null ? 10.0 : 14.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ]
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: trailing,
                ),
              if (isTappable && trailing == null)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary.withOpacity(0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
