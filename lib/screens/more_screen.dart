import 'package:flutter/material.dart';
import 'zikr_screen.dart';
import 'dua_screen.dart';
import 'calendar_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';


class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _showSupportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Support the App ❤️"),
        content: const Text("Choose an amount"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openSupportLink('https://buy.stripe.com/3cI28qfxR9y25NAgam1Nu02');
            },
            child: const Text("\$0.99"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openSupportLink('https://buy.stripe.com/cNicN499tcKe3Fs8HU1Nu00');
            },
            child: const Text("\$1.99"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openSupportLink('https://buy.stripe.com/eVq5kCbhBh0ub7Ugam1Nu01');
            },
            child: const Text("\$2.99"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _rateApp() async {
    final Uri url = Uri.parse(
      'https://apps.apple.com/us/app/sala-prayer-times/id6759267391',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openSupportLink(String link) async {
    final Uri url = Uri.parse(link);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("More"),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildItem(
            context,
            imagePath: 'assets/zikr_icon.png',
            title: "",
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
            imagePath: 'assets/duas_icon.png',
            title: "",
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
            imagePath: 'assets/hijri_calendar.png',
            title: "",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarScreen(),
                ),
              );
            },
          ),
          _buildItem(
            context,
            imagePath: 'assets/share_app.png',
            title: "",
            onTap: () {
              Share.share(
                "Check out my prayer app! 🕌\n\nDownload it here:\nhttps://apps.apple.com/us/app/sala-prayer-times/id6759267391",
              );
            },
          ),
          _buildItem(
            context,
            imagePath: 'assets/rate_app.png',
            title: "",
            onTap: () async {
              await _rateApp();
            },
          ),
          _buildItem(
            context,
            imagePath: 'assets/support.png',
            title: "",
            onTap: () async {_showSupportOptions(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, {
        String? imagePath,
        required String title,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: imagePath != null
                ? Image.asset(
              imagePath,
              fit: BoxFit.contain,
            )
                : const SizedBox(),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}