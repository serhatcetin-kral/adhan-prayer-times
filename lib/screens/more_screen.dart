// import 'package:flutter/material.dart';
// import 'zikr_screen.dart';
// import 'dua_screen.dart';
// import 'calendar_screen.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
//
//
// class MoreScreen extends StatelessWidget {
//   const MoreScreen({super.key});
//
//   void _showSupportOptions(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Support the App ❤️"),
//         content: const Text("Choose an amount"),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _openSupportLink('https://buy.stripe.com/3cI28qfxR9y25NAgam1Nu02');
//             },
//             child: const Text("\$0.99"),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _openSupportLink('https://buy.stripe.com/cNicN499tcKe3Fs8HU1Nu00');
//             },
//             child: const Text("\$1.99"),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _openSupportLink('https://buy.stripe.com/eVq5kCbhBh0ub7Ugam1Nu01');
//             },
//             child: const Text("\$2.99"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("Cancel"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _rateApp() async {
//     final Uri url = Uri.parse(
//       'https://apps.apple.com/us/app/sala-prayer-times/id6759267391',
//     );
//
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     }
//   }
//
//   Future<void> _openSupportLink(String link) async {
//     final Uri url = Uri.parse(link);
//
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("More"),
//         centerTitle: true,
//       ),
//       body: GridView.count(
//         crossAxisCount: 2,
//         padding: const EdgeInsets.all(16),
//         mainAxisSpacing: 20,
//         crossAxisSpacing: 20,
//         childAspectRatio: 0.9,
//         children: [
//           _buildItem(
//             context,
//             imagePath: 'assets/zikr_icon.png',
//             title: "",
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const ZikrScreen(),
//                 ),
//               );
//             },
//           ),
//           _buildItem(
//             context,
//             imagePath: 'assets/duas_icon.png',
//             title: "",
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const DuaScreen(),
//                 ),
//               );
//             },
//           ),
//           _buildItem(
//             context,
//             imagePath: 'assets/hijri_calendar.png',
//             title: "",
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const CalendarScreen(),
//                 ),
//               );
//             },
//           ),
//           _buildItem(
//             context,
//             imagePath: 'assets/share_app.png',
//             title: "",
//             onTap: () {
//               Share.share(
//                 "Check out my prayer app! 🕌\n\nDownload it here:\nhttps://apps.apple.com/us/app/sala-prayer-times/id6759267391",
//               );
//             },
//           ),
//           _buildItem(
//             context,
//             imagePath: 'assets/rate_app.png',
//             title: "",
//             onTap: () async {
//               await _rateApp();
//             },
//           ),
//           _buildItem(
//             context,
//             imagePath: 'assets/support.png',
//             title: "",
//             onTap: () async {_showSupportOptions(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItem(
//       BuildContext context, {
//         String? imagePath,
//         required String title,
//         required VoidCallback onTap,
//       }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 130,
//             height: 130,
//             child: imagePath != null
//                 ? Image.asset(
//               imagePath,
//               fit: BoxFit.contain,
//             )
//                 : const SizedBox(),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'zikr_screen.dart';
import 'dua_screen.dart';
import 'calendar_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // --- SUPPORT DIALOG ---
  void _showSupportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Support the App ❤️"),
        content: const Text("Choose an amount"),
        actions: [
          _supportBtn(context, "\$0.99", 'https://buy.stripe.com/3cI28qfxR9y25NAgam1Nu02'),
          _supportBtn(context, "\$1.99", 'https://buy.stripe.com/cNicN499tcKe3Fs8HU1Nu00'),
          _supportBtn(context, "\$2.99", 'https://buy.stripe.com/eVq5kCbhBh0ub7Ugam1Nu01'),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ],
      ),
    );
  }

  Widget _supportBtn(BuildContext context, String label, String link) {
    return TextButton(
      onPressed: () async {
        Navigator.pop(context);
        final url = Uri.parse(link);
        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: Text(label),
    );
  }

  Future<void> _rateApp() async {
    final Uri url = Uri.parse('https://apps.apple.com/us/app/sala-prayer-times/id6759267391');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Tablet: 3 columns, Phone: 2 columns
    int crossAxisCount = screenWidth > 600 ? 3 : 2;
    double spacing = screenWidth > 600 ? 30 : 20;

    return Scaffold(
      appBar: AppBar(
        title: const Text("More"),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          // Prevents items from stretching too wide on iPad Pro
          constraints: const BoxConstraints(maxWidth: 900),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            padding: EdgeInsets.all(spacing),
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1.0, // Keeps icons perfectly square
            children: [
              _buildItem(context, 'assets/zikr_icon.png', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZikrScreen()));
              }),
              _buildItem(context, 'assets/duas_icon.png', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DuaScreen()));
              }),
              _buildItem(context, 'assets/hijri_calendar.png', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
              }),
              _buildItem(context, 'assets/share_app.png', () {
                Share.share("Check out my prayer app! 🕌\nhttps://apps.apple.com/us/app/sala-prayer-times/id6759267391");
              }),
              _buildItem(context, 'assets/rate_app.png', () async => await _rateApp()),
              _buildItem(context, 'assets/support.png', () => _showSupportOptions(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Adding a very light shadow makes the icons "pop" on a white background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}