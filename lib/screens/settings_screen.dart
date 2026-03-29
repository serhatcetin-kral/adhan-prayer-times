import 'package:flutter/material.dart';
import '../models/calculation_method.dart';
import '../models/madhab_type.dart';
import '../services/settings_service.dart';
import 'main_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  CalculationMethod selectedMethod = CalculationMethod.isna;
  MadhabType selectedMadhab = MadhabType.standard;

  bool notificationsEnabled = true;
  int offset = 0;

  Map<String, bool> adhan = {};
  Map<String, bool> popup = {};
  Map<String, int> prayerOffsets = {};

  final List<String> prayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
    'Sunrise',
  ];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  // ===============================
  // LOAD ALL SETTINGS
  // ===============================
  Future<void> loadSettings() async {
    selectedMethod = await SettingsService.getCalculationMethod();
    selectedMadhab = await SettingsService.getMadhab();
    notificationsEnabled = await SettingsService.getNotificationsEnabled();
    offset = await SettingsService.getOffset();

    for (final p in prayers) {
      adhan[p] = await SettingsService.isAdhanEnabled(p);
      popup[p] = await SettingsService.isPopupEnabled(p);
      prayerOffsets[p] = await SettingsService.getPrayerOffset(p);
    }

    setState(() {});
  }

  // ===============================
  // SAVE ALL SETTINGS
  // ===============================
  Future<void> saveSettings() async {
    await SettingsService.saveCalculationMethod(selectedMethod);
    await SettingsService.saveMadhab(selectedMadhab);
    await SettingsService.setNotificationsEnabled(notificationsEnabled);
    await SettingsService.setOffset(offset);

    // ✅ save per prayer notification settings
    for (final p in prayers) {
      await SettingsService.setAdhanEnabled(p, adhan[p] ?? true);
      await SettingsService.setPopupEnabled(p, popup[p] ?? true);
      await SettingsService.setPrayerOffset(p, prayerOffsets[p] ?? 0);
    }

    // 🔥 mark first launch done
    await SettingsService.completeFirstLaunch();

    if (!mounted) return;

    // 🔥 GO TO MAIN SCREEN
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
    );
  }

  // ===============================
  // RESET ALL OFFSETS
  // ===============================
  void resetAllOffsets() {
    setState(() {
      offset = 0;
      for (final p in prayers) {
        prayerOffsets[p] = 0;
      }
    });
  }

  // ===============================
  // INDIVIDUAL OFFSET UI
  // ===============================
  Widget buildOffsetControl(String prayer) {
    final current = prayerOffsets[prayer] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              prayer,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() {
                      if (current > -10) {
                        prayerOffsets[prayer] = current - 1;
                      }
                    });
                  },
                ),
                Text(
                  "$current min",
                  style: const TextStyle(fontSize: 15),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      if (current < 10) {
                        prayerOffsets[prayer] = current + 1;
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // PRAYER NOTIFICATION UI
  // ===============================
  Widget buildPrayerNotificationCard(String prayer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          ListTile(
            title: Text(
              prayer,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Text("Adhan"),
                    Switch(
                      value: adhan[prayer] ?? true,
                      onChanged: (v) {
                        setState(() => adhan[prayer] = v);
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Popup"),
                    Switch(
                      value: popup[prayer] ?? true,
                      onChanged: (v) {
                        setState(() => popup[prayer] = v);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // 📍 Calculation Method
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Calculation Method",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          ...CalculationMethod.values.map((method) {
            return RadioListTile(
              title: Text(method.displayName),
              value: method,
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() => selectedMethod = value!);
              },
            );
          }),

          const Divider(),

          // 📍 Madhab
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Madhab",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          ...MadhabType.values.map((madhab) {
            return RadioListTile(
              title: Text(madhab.displayName),
              value: madhab,
              groupValue: selectedMadhab,
              onChanged: (value) {
                setState(() => selectedMadhab = value!);
              },
            );
          }),

          const Divider(),

          // 🔔 MASTER NOTIFICATION
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),

          const Divider(),

          // 🔔 PER PRAYER NOTIFICATIONS
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Prayer Notifications",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          ...prayers.map((p) => buildPrayerNotificationCard(p)),

          const Divider(),

          // ⏰ INDIVIDUAL PRAYER OFFSETS
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Prayer Time Offsets",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          ...prayers.map((p) => buildOffsetControl(p)),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: resetAllOffsets,
              icon: const Icon(Icons.refresh),
              label: const Text("Reset All Offsets"),
            ),
          ),

          const Divider(),

          // 🌍 GLOBAL OFFSET
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Global Offset: $offset min",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  min: -10,
                  max: 10,
                  divisions: 20,
                  value: offset.toDouble(),
                  onChanged: (value) {
                    setState(() => offset = value.toInt());
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ✅ SAVE
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: saveSettings,
              icon: const Icon(Icons.save),
              label: const Text("Save Settings"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}