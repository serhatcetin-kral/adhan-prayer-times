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

  final List<String> prayers = [
    'Fajr','Dhuhr','Asr','Maghrib','Isha','Sunrise'
  ];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  // 🔥 LOAD ALL SETTINGS
  Future<void> loadSettings() async {
    selectedMethod = await SettingsService.getCalculationMethod();
    selectedMadhab = await SettingsService.getMadhab();
    notificationsEnabled = await SettingsService.getNotificationsEnabled();
    offset = await SettingsService.getOffset();

    for (final p in prayers) {
      adhan[p] = await SettingsService.isAdhanEnabled(p);
      popup[p] = await SettingsService.isPopupEnabled(p);
    }

    setState(() {});
  }

  // 🔥 SAVE ALL SETTINGS
  Future<void> saveAndContinue() async {
    await SettingsService.saveCalculationMethod(selectedMethod);
    await SettingsService.saveMadhab(selectedMadhab);
    await SettingsService.setNotificationsEnabled(notificationsEnabled);
    await SettingsService.setOffset(offset);

    // 🔥 SAVE PER PRAYER SETTINGS
    for (final p in prayers) {
      await SettingsService.setAdhanEnabled(p, adhan[p]!);
      await SettingsService.setPopupEnabled(p, popup[p]!);
    }

    await SettingsService.completeFirstLaunch();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [

          // 📍 Calculation Method
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Calculation Method",
                style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: Text("Madhab",
                style: TextStyle(fontWeight: FontWeight.bold)),
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

          // 🔥 PER PRAYER SETTINGS
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Prayer Notifications",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          ...prayers.map((p) {
            return Card(
              child: Column(
                children: [
                  ListTile(title: Text(p)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Text("Adhan"),
                          Switch(
                            value: adhan[p] ?? true,
                            onChanged: (v) =>
                                setState(() => adhan[p] = v),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          const Text("Popup"),
                          Switch(
                            value: popup[p] ?? true,
                            onChanged: (v) =>
                                setState(() => popup[p] = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const Divider(),

          // ⏰ Offset
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text("Offset: $offset min",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
            child: ElevatedButton(
              onPressed: saveAndContinue,
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}