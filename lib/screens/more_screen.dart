// import 'package:flutter/material.dart';
//
// import 'about_screen.dart';
// import 'dua_screen.dart';
// import 'zikr_screen.dart';
//
// class MoreScreen extends StatelessWidget {
//   const MoreScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("More"),
//         centerTitle: true,
//       ),
//       body: ListView(
//         children: [
//           _buildItem(
//             context,
//             icon: Icons.info,
//             title: "About",
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const AboutScreen(),
//                 ),
//               );
//             },
//           ),
//
//           _buildItem(
//             context,
//             icon: Icons.menu_book,
//             title: "Dua",
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const DuaScreen(),
//                 ),
//               );
//             },
//           ),
//
//           _buildItem(
//             context,
//             icon: Icons.self_improvement,
//             title: "Zikr",
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const ZikrScreen(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItem(
//       BuildContext context, {
//         required IconData icon,
//         required String title,
//         required VoidCallback onTap,
//       }) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.teal),
//       title: Text(title),
//       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//       onTap: onTap,
//     );
//   }
// }

///////////
import 'package:flutter/material.dart';
import 'zikr_screen.dart';
import 'dua_screen.dart';
import 'calendar_screen.dart';
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("More"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildItem(
            context,
            icon: Icons.self_improvement,
            title: "Zikr",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ZikrScreen(),
                ),
              );
            },
          ),
          _buildItem(
            context,
            icon: Icons.self_improvement,
            title: "Duas",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DuaScreen(),
                ),
              );
            },
          ),
          _buildItem(
            context,
            icon: Icons.self_improvement,
            title: "Hijri Calendar",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}