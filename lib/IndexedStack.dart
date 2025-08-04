import 'package:flutter/material.dart';
import 'widget/KonekteBottomBar.dart';
import 'main.dart';
import 'pages/chat_page.dart';
import 'pages/conversations_page.dart';
import 'pages/ParametresClairsPage.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    SwipePage(),
    // SuperlikePage(),
    // LikePage(),
    ConversationsPage(),
    ParametresClairsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: KonekteBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
