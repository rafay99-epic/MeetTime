import 'package:flutter/material.dart';
import 'package:meettime/widgets/appbar.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MeetTimeAppBar(
        title: 'Settings',
        showBack: false,
        showSettings: false,
      ),
      body: Center(
        child: Text('Settings'),
      ),
    );
  }
}
