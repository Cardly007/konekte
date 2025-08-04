// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'ParametresClairsPage.dart';
// import 'chat_page.dart';
// import 'conversations_page.dart';
// import 'main.dart';

// class MainScaffold extends StatefulWidget {
//   const MainScaffold({super.key});

//   @override
//   State<MainScaffold> createState() => _MainScaffoldState();
// }

// class _MainScaffoldState extends State<MainScaffold> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//   SwipePage(),                // index 0 - Home
//   Placeholder(),              // index 1 - Superlike
//   Placeholder(),              // index 2 - Like
//   ConversationsPage(),        // index 3 - Chat
//   ParametresClairsPage(),     // index 4 - Profile
// ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.black,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.grey,
//         currentIndex: _selectedIndex,
//         items: const [
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.house),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.star),
//             label: 'Superlike',
//           ),
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.heart),
//             label: 'Like',
//           ),
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.commentDots),
//             label: 'Chat',
//           ),
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.user),
//             label: 'Profile',
//           ),
//         ],
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'pages/chat_page.dart';
import 'pages/conversations_page.dart';
import 'pages/ParametresClairsPage.dart';
import 'main.dart';
import 'widget/KonekteBottomBar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    SwipePage(),
    Placeholder(), // Superlike
    Placeholder(), // Like
    ConversationsPage(),
    ParametresClairsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // bottomNavigationBar: KonekteBottomBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
      bottomNavigationBar: KonekteBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
