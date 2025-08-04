// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../main.dart';
// import '../chat_page.dart';
// import '../conversations_page.dart';
// import '../ParametresClairsPage.dart';

// class KonekteBottomBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const KonekteBottomBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       backgroundColor: Colors.black,
//       selectedItemColor: Colors.white,
//       unselectedItemColor: Colors.grey,
//       currentIndex: currentIndex,
//       items: const [
//         BottomNavigationBarItem(
//           icon: FaIcon(FontAwesomeIcons.house),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: FaIcon(FontAwesomeIcons.star),
//           label: 'Superlike',
//         ),
//         BottomNavigationBarItem(
//           icon: FaIcon(FontAwesomeIcons.heart),
//           label: 'Like',
//         ),
//         BottomNavigationBarItem(
//           icon: FaIcon(FontAwesomeIcons.commentDots),
//           label: 'Chat',
//         ),
//         BottomNavigationBarItem(
//           icon: FaIcon(FontAwesomeIcons.user),
//           label: 'Profile',
//         ),
//       ],
//       onTap: onTap,
//     );
//     // return BottomNavigationBar(
//     //   type: BottomNavigationBarType.fixed,
//     //   backgroundColor: Colors.black,
//     //   selectedItemColor: Colors.white,
//     //   unselectedItemColor: Colors.grey,
//     //   currentIndex: currentIndex,
//     //   onTap: onTap,
//     //   items: const [
//     //     BottomNavigationBarItem(
//     //       icon: FaIcon(FontAwesomeIcons.house),
//     //       label: 'Home',
//     //     ),
//     //     BottomNavigationBarItem(
//     //       icon: FaIcon(FontAwesomeIcons.star),
//     //       label: 'Superlike',
//     //     ),
//     //     BottomNavigationBarItem(
//     //       icon: FaIcon(FontAwesomeIcons.heart),
//     //       label: 'Like',
//     //     ),
//     //     BottomNavigationBarItem(
//     //       icon: FaIcon(FontAwesomeIcons.commentDots),
//     //       label: 'Chat',
//     //     ),
//     //     BottomNavigationBarItem(
//     //       icon: FaIcon(FontAwesomeIcons.user),
//     //       label: 'Profile',
//     //     ),
//     //   ],
//     // );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KonekteBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const KonekteBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // backgroundColor: const Color.fromARGB(255, 7, 7, 7),
      backgroundColor: const Color.fromARGB(145, 255, 254, 254),
      selectedItemColor: const Color.fromARGB(255, 101, 99, 99),
      unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.house),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.star),
          label: 'Superlike',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.heart),
          label: 'Like',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.commentDots),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.user),
          label: 'Profile',
        ),
      ],
    );
  }
}
