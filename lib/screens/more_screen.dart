import 'package:flutter/material.dart';
import 'settings_screen.dart';

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
            icon: Icons.info,
            title: "About",
            onTap: () {},
          ),


          _buildItem(
            context,
            icon: Icons.menu_book,
            title: "Dua",
            onTap: () {},
          ),

          _buildItem(
            context,
            icon: Icons.self_improvement,
            title: "Zikr",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context,
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}