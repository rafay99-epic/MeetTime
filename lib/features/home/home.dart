import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:meettime/features/chatbot/chatbot.dart';
import 'package:meettime/features/history/history.dart';
import 'package:meettime/features/settings/setting.dart';
import 'package:meettime/features/time_convter/time_convter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<Home> {
  int _selectedIndex = 0;
  PageController? _pageController;

  final List<Widget> _pages = const [
    TimeConverterScreen(),
    HistoryConverter(),
    ChatbotScreen(),
    Setting(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController?.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: GNav(
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
        backgroundColor: colorScheme.primary,
        color: colorScheme.onPrimary,
        activeColor: colorScheme.onPrimary,
        tabBackgroundColor: colorScheme.onPrimary.withOpacity(0.1),
        padding: const EdgeInsets.all(15),
        tabs: [
          GButton(
            icon: LineIcons.clockAlt,
            text: 'Time Converter',
            iconColor: colorScheme.onPrimary,
          ),
          GButton(
            icon: LineIcons.history,
            text: 'History',
            iconColor: colorScheme.onPrimary,
          ),
          GButton(
            icon: LineIcons.robot,
            text: 'Chatbot',
            iconColor: colorScheme.onPrimary,
          ),
          GButton(
            icon: LineIcons.cog,
            text: 'Settings',
            iconColor: colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}
