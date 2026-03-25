import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vibration/vibration.dart';

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

      final city = await LocationNameService.getLocationName(
        pos.latitude,
        pos.longitude,
      );

      final bearing = QiblaService.bearingToKaaba(
        userLat: pos.latitude,
        userLng: pos.longitude,
      );

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

  bool _isAligned(double diff) {
    return diff.abs() <= 8;
  }

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
          ? Center(
        child: Text(
          error!,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.heading == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Compass not available.\n\nTry moving your phone in a figure 8.\nIf it still doesn’t work, your device sensor may need calibration.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final heading = snapshot.data!.heading!;
          final diff = QiblaService.shortestAngleDifference(
            qiblaBearing!,
            heading,
          );
          final aligned = _isAligned(diff);

          _handleVibration(aligned);

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Text(
                      locationName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Qibla: ${qiblaBearing!.toStringAsFixed(1)}°",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Heading: ${heading.toStringAsFixed(1)}°",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Compass Circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                            border: Border.all(
                              color: Colors.teal,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        const Positioned(
                          top: 18,
                          child: Text(
                            "N",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Positioned(
                          bottom: 18,
                          child: Text(
                            "S",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),

                        const Positioned(
                          left: 18,
                          child: Text(
                            "W",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),

                        const Positioned(
                          right: 18,
                          child: Text(
                            "E",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),

                        // Arrow
                        Transform.rotate(
                          angle: diff * (math.pi / 180),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "🕋",
                                style: TextStyle(fontSize: 30),
                              ),
                              Icon(
                                Icons.navigation,
                                size: 150,
                                color: aligned
                                    ? Colors.green
                                    : Colors.teal,
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.circle,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      aligned
                          ? "✅ You are facing Qibla"
                          : "Turn slowly until the Kaaba arrow points up",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: aligned ? Colors.green : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      aligned
                          ? "You are aligned within 8°"
                          : "Difference: ${diff.abs().toStringAsFixed(1)}°",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Tip: If the compass seems wrong, move your phone in a figure 8 to calibrate it.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
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