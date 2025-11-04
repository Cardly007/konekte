import 'package:flutter/material.dart';
import 'pages/conversations_page.dart';
import 'pages/parametres_clairs_page.dart';
import 'pages/swipe_page.dart'; // Importer la nouvelle page
import 'widget/KonekteBottomBar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // La liste des pages inclut maintenant la vraie SwipePage
  final List<Widget> _pages = [
    const SwipePage(),
    const ConversationsPage(),
    const ParametresClairsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
