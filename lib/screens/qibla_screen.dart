// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_compass/flutter_compass.dart';
// import 'package:vibration/vibration.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../services/location_service.dart';
// import '../services/location_name_service.dart';
// import '../services/qibla_service.dart';
//
// class QiblaScreen extends StatefulWidget {
//   const QiblaScreen({super.key});
//
//   @override
//   State<QiblaScreen> createState() => _QiblaScreenState();
// }
//
// class _QiblaScreenState extends State<QiblaScreen> {
//   double? qiblaBearing;
//   String locationName = "Loading location...";
//   bool isLoading = true;
//   String? error;
//   bool hasVibrated = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadQibla();
//   }
//
//   Future<void> _loadQibla() async {
//     try {
//       final pos = await LocationService.getUserLocation();
//
//       if (pos == null) {
//         setState(() {
//           error = "Location unavailable";
//           isLoading = false;
//         });
//         return;
//       }
//
//       final city = await LocationNameService.getLocationName(
//         pos.latitude,
//         pos.longitude,
//       );
//
//       final bearing = QiblaService.bearingToKaaba(
//         userLat: pos.latitude,
//         userLng: pos.longitude,
//       );
//
//       setState(() {
//         qiblaBearing = bearing;
//         locationName = city;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = "Unable to load Qibla";
//         isLoading = false;
//       });
//     }
//   }
//
//   // ============================
//   // GOOGLE QIBLA FINDER BUTTON
//   // ============================
//   Future<void> _openGoogleQibla() async {
//     final url = Uri.parse('https://qiblafinder.withgoogle.com');
//
//     try {
//       await launchUrl(
//         url,
//         mode: LaunchMode.externalApplication,
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Could not open Google Qibla Finder"),
//         ),
//       );
//     }
//   }
//
//   // ============================
//   // ALIGNMENT CHECK
//   // ============================
//   bool _isAligned(double diff) {
//     return diff.abs() <= 8;
//   }
//
//   // ============================
//   // VIBRATION
//   // ============================
//   Future<void> _handleVibration(bool aligned) async {
//     if (aligned && !hasVibrated) {
//       if (await Vibration.hasVibrator() ?? false) {
//         Vibration.vibrate(duration: 300);
//       }
//       hasVibrated = true;
//     } else if (!aligned) {
//       hasVibrated = false;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Qibla Finder"),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//           ? Center(
//         child: Text(
//           error!,
//           style: const TextStyle(fontSize: 16),
//           textAlign: TextAlign.center,
//         ),
//       )
//           : StreamBuilder<CompassEvent>(
//         stream: FlutterCompass.events,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData || snapshot.data?.heading == null) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Text(
//                   "Compass not available.\n\nTry moving your phone in a figure 8.\nIf it still doesn’t work, your device sensor may need calibration.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             );
//           }
//
//           final heading = snapshot.data!.heading!;
//           final diff = QiblaService.shortestAngleDifference(
//             qiblaBearing!,
//             heading,
//           );
//           final aligned = _isAligned(diff);
//
//           _handleVibration(aligned);
//
//           return SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 16,
//                 ),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 19),
//
//                     Text(
//                       locationName,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//
//                     const SizedBox(height: 9),
//
//                     Text(
//                       "Qibla: ${qiblaBearing!.toStringAsFixed(1)}°",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//
//                     const SizedBox(height: 4),
//
//                     Text(
//                       "Heading: ${heading.toStringAsFixed(1)}°",
//                       style: const TextStyle(
//                         fontSize: 15,
//                         color: Colors.grey,
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     // Compass Circle
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         Container(
//                           width: 290,
//                           height: 290,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.grey.shade100,
//                             border: Border.all(
//                               color: Colors.teal,
//                               width: 4,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.08),
//                                 blurRadius: 12,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const Positioned(
//                           top: 18,
//                           child: Text(
//                             "N",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//
//                         const Positioned(
//                           bottom: 18,
//                           child: Text(
//                             "S",
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ),
//
//                         const Positioned(
//                           left: 18,
//                           child: Text(
//                             "W",
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ),
//
//                         const Positioned(
//                           right: 18,
//                           child: Text(
//                             "E",
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ),
//
//                         // Qibla Arrow
//                         Transform.rotate(
//                           angle: diff * (math.pi / 180),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Text(
//                                 "🕋",
//                                 style: TextStyle(fontSize: 30),
//                               ),
//                               Icon(
//                                 Icons.navigation,
//                                 size: 150,
//                                 color: aligned
//                                     ? Colors.green
//                                     : Colors.teal,
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const Icon(
//                           Icons.circle,
//                           size: 18,
//                           color: Colors.black54,
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 26),
//
//                     Text(
//                       aligned
//                           ? "✅ You are facing Qibla"
//                           : "Turn slowly until the Kaaba arrow points up",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: aligned ? Colors.green : Colors.black,
//                       ),
//                     ),
//
//                     const SizedBox(height: 12),
//
//                     Text(
//                       aligned
//                           ? "You are aligned within 8°"
//                           : "Difference: ${diff.abs().toStringAsFixed(1)}°",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // Tip Box
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.teal.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Text(
//                         "Tip: If the compass seems wrong, move your phone in a figure 8 to calibrate it.",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 15),
//                       ),
//                     ),
//
//
//
//                     const SizedBox(height: 16),
//
// // 🌍 GOOGLE QIBLA FINDER (MOVED UP + POLISHED)
//                     Container(
//                       width: double.infinity,
//                       margin: const EdgeInsets.only(bottom: 14),
//                       child: GestureDetector(
//                         onTap: _openGoogleQibla,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF0F9D94), Color(0xFF13B8A6)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.teal.withOpacity(0.22),
//                                 blurRadius: 14,
//                                 offset: const Offset(0, 5),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: const [
//                               Icon(
//                                 Icons.explore_rounded,
//                                 color: Colors.white,
//                                 size: 22,
//                               ),
//                               SizedBox(width: 10),
//                               Flexible(
//                                 child: Text(
//                                   "Open Google AR Qibla Finder",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 15.5,
//                                     fontWeight: FontWeight.w600,
//                                     letterSpacing: 0.2,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const Text(
//                       "Use Google’s AR Qibla if your compass feels inaccurate.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 13.5,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
// // 💡 TIP BOX (NOW BELOW BUTTON)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.teal.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Text(
//                         "Tip: If the compass seems wrong, move your phone in a figure 8 to calibrate it.",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 14.5),
//                       ),
//                     ),
//
//                     const SizedBox(height: 8),
//
//                     const Text(
//                       "Optional: Use Google’s AR Qibla if your compass feels inaccurate.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 13.5,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

/////////////
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_compass/flutter_compass.dart';
// import 'package:vibration/vibration.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../services/location_service.dart';
// import '../services/location_name_service.dart';
// import '../services/qibla_service.dart';
//
// class QiblaScreen extends StatefulWidget {
//   const QiblaScreen({super.key});
//
//   @override
//   State<QiblaScreen> createState() => _QiblaScreenState();
// }
//
// class _QiblaScreenState extends State<QiblaScreen> {
//   double? qiblaBearing;
//   String locationName = "Loading location...";
//   bool isLoading = true;
//   String? error;
//   bool hasVibrated = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadQibla();
//   }
//
//   Future<void> _loadQibla() async {
//     try {
//       final pos = await LocationService.getUserLocation();
//       if (pos == null) {
//         setState(() {
//           error = "Location unavailable";
//           isLoading = false;
//         });
//         return;
//       }
//
//       final city = await LocationNameService.getLocationName(pos.latitude, pos.longitude);
//       final bearing = QiblaService.bearingToKaaba(userLat: pos.latitude, userLng: pos.longitude);
//
//       setState(() {
//         qiblaBearing = bearing;
//         locationName = city;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = "Unable to load Qibla";
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _openGoogleQibla() async {
//     final url = Uri.parse('https://qiblafinder.withgoogle.com');
//     try {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Could not open Google Qibla Finder")),
//       );
//     }
//   }
//
//   bool _isAligned(double diff) => diff.abs() <= 8;
//
//   Future<void> _handleVibration(bool aligned) async {
//     if (aligned && !hasVibrated) {
//       if (await Vibration.hasVibrator() ?? false) {
//         Vibration.vibrate(duration: 300);
//       }
//       hasVibrated = true;
//     } else if (!aligned) {
//       hasVibrated = false;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Qibla Finder"),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//           ? Center(child: Text(error!, style: const TextStyle(fontSize: 16)))
//           : StreamBuilder<CompassEvent>(
//         stream: FlutterCompass.events,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData || snapshot.data?.heading == null) {
//             return const Center(child: Text("Compass not available."));
//           }
//
//           final heading = snapshot.data!.heading!;
//           final diff = QiblaService.shortestAngleDifference(qiblaBearing!, heading);
//           final aligned = _isAligned(diff);
//           _handleVibration(aligned);
//
//           return SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     Text(locationName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     Text("Qibla: ${qiblaBearing!.toStringAsFixed(1)}°", style: const TextStyle(color: Colors.grey)),
//                     const SizedBox(height: 30),
//
//                     // --- COMPASS CIRCLE ---
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         Container(
//                           width: 280,
//                           height: 280,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.grey.shade100,
//                             border: Border.all(color: Colors.teal, width: 4),
//                           ),
//                         ),
//                         Transform.rotate(
//                           angle: diff * (math.pi / 180),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Text("🕋", style: TextStyle(fontSize: 30)),
//                               Icon(Icons.navigation, size: 140, color: aligned ? Colors.green : Colors.teal),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 26),
//                     Text(
//                       aligned ? "✅ Facing Qibla" : "Rotate your phone",
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: aligned ? Colors.green : Colors.black),
//                     ),
//
//                     const SizedBox(height: 40),
//
//                     // --- GOOGLE QIBLA DROP BUTTON ---
//                     GestureDetector(
//                       onTap: _openGoogleQibla,
//                       child: Column(
//                         children: [
//                           // The Pin/Drop Shape
//                           Container(
//                             width: 70,
//                             height: 70,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFF4285F4), // Google Pin Blue
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(40),
//                                 topRight: Radius.circular(40),
//                                 bottomLeft: Radius.circular(40),
//                                 bottomRight: Radius.circular(4), // Teardrop point
//                               ),
//                             ),
//                             child: RotationTransition(
//                               turns: const AlwaysStoppedAnimation(45 / 360),
//                               child: Center(
//                                 child: RotationTransition(
//                                   turns: const AlwaysStoppedAnimation(-45 / 360),
//                                   child: const Text("🕋", style: TextStyle(fontSize: 32)),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           const Text(
//                             "Google Qibla Finder",
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           const Text(
//                             "Use AR if compass feels inaccurate",
//                             style: TextStyle(fontSize: 13, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     // --- TIP BOX ---
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.teal.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Text(
//                         "Tip: Move your phone in a figure 8 to calibrate sensors.",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/location_service.dart';
import '../services/location_name_service.dart';
import '../services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? qiblaBearing;
  String locationName = "Loading location...";
  bool isLoading = true;
  String? error;
  bool hasVibrated = false;

  @override
  void initState() {
    super.initState();
    _loadQibla();
  }

  Future<void> _loadQibla() async {
    try {
      final pos = await LocationService.getUserLocation();
      if (pos == null) {
        setState(() {
          error = "Location unavailable";
          isLoading = false;
        });
        return;
      }
      final city = await LocationNameService.getLocationName(pos.latitude, pos.longitude);
      final bearing = QiblaService.bearingToKaaba(userLat: pos.latitude, userLng: pos.longitude);
      setState(() {
        qiblaBearing = bearing;
        locationName = city;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Unable to load Qibla";
        isLoading = false;
      });
    }
  }

  Future<void> _openGoogleQibla() async {
    final url = Uri.parse('https://qiblafinder.withgoogle.com');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Qibla Finder")),
      );
    }
  }

  bool _isAligned(double diff) => diff.abs() <= 8;

  Future<void> _handleVibration(bool aligned) async {
    if (aligned && !hasVibrated) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 300);
      }
      hasVibrated = true;
    } else if (!aligned) {
      hasVibrated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Qibla Finder"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center))
          : StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.heading == null) {
            return const Center(child: Text("Compass not available.", textAlign: TextAlign.center));
          }

          final heading = snapshot.data!.heading!;
          final diff = QiblaService.shortestAngleDifference(qiblaBearing!, heading);
          final aligned = _isAligned(diff);
          _handleVibration(aligned);

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(locationName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 5),
                    Text("Qibla: ${qiblaBearing!.toStringAsFixed(1)}° | Heading: ${heading.toStringAsFixed(1)}°",
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 20),

                    // --- SMALLER COMPASS CIRCLE ---
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 240, height: 240, // Reduced from 290
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.teal, width: 3),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                          ),
                        ),
                        const Positioned(top: 12, child: Text("N", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                        const Positioned(bottom: 12, child: Text("S", style: TextStyle(fontSize: 16))),
                        const Positioned(left: 12, child: Text("W", style: TextStyle(fontSize: 16))),
                        const Positioned(right: 12, child: Text("E", style: TextStyle(fontSize: 16))),
                        Transform.rotate(
                          angle: diff * (math.pi / 180),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("🕋", style: TextStyle(fontSize: 28)),
                              Icon(Icons.navigation, size: 120, color: aligned ? Colors.green : Colors.teal), // Smaller Icon
                            ],
                          ),
                        ),
                        const Icon(Icons.circle, size: 14, color: Colors.black54),
                      ],
                    ),

                    const SizedBox(height: 15),
                    Text(
                      aligned ? "✅ Facing Qibla" : "Rotate your phone",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: aligned ? Colors.green : Colors.black),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      aligned ? "Aligned within 8°" : "Diff: ${diff.abs().toStringAsFixed(1)}°",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    // Compact Tip Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                      child: const Text("Tip: Move phone in figure 8 to calibrate.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                    ),

                    const SizedBox(height: 25),

                    // --- GOOGLE QIBLA PIN BUTTON ---
                    GestureDetector(
                      onTap: _openGoogleQibla,
                      child: Column(
                        children: [
                          Transform.rotate(
                            angle: 45 * (math.pi / 180),
                            child: Container(
                              width: 80, height: 80, // Size remains nice and visible
                              decoration: const BoxDecoration(
                                color: Color(0xFF4285F4),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(6),
                                ),
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))],
                              ),
                              child: Center(
                                child: Transform.rotate(
                                  angle: -45 * (math.pi / 180),
                                  child: const Text("🕋", style: TextStyle(fontSize: 34)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("Google Qibla Finder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Text("Open Google AR for more accuracy", style: TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
                    // Optional footer text kept small
                    const Text("Use Google’s AR Qibla if compass feels inaccurate.",
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}