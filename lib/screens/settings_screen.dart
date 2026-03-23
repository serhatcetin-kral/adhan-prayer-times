import 'package:flutter/material.dart';
import '../models/calculation_method.dart';
import '../models/madhab_type.dart';
import '../services/settings_service.dart';
import 'prayer_screen.dart';
import 'main_screen.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  CalculationMethod selectedMethod = CalculationMethod.mwl;
  MadhabType selectedMadhab = MadhabType.standard;

  bool notificationsEnabled = true;
  int offset = 0;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    selectedMethod = await SettingsService.getCalculationMethod();
    selectedMadhab = await SettingsService.getMadhab();
    notificationsEnabled = await SettingsService.getNotificationsEnabled();
    offset = await SettingsService.getOffset();

    setState(() {});
  }

  Future<void> saveAndContinue() async {
    await SettingsService.saveCalculationMethod(selectedMethod);
    await SettingsService.saveMadhab(selectedMadhab);
    await SettingsService.setNotificationsEnabled(notificationsEnabled);
    await SettingsService.setOffset(offset);

    // 🔰 First launch completed
    await SettingsService.completeFirstLaunch();

    // 👉 Go to prayer screen
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

          // 📍 Madhhab
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

          // 🔔 Notifications
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),

          const Divider(),

          // ⏰ Offset Slider
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Adjust Prayer Time Offset: $offset min",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  min: -10,
                  max: 10,
                  divisions: 20,
                  value: offset.toDouble(),
                  label: "$offset",
                  onChanged: (value) {
                    setState(() => offset = value.toInt());
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ✅ SAVE BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: saveAndContinue,
              child: const Text("Save & Continue"),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}