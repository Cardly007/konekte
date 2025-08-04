import 'package:flutter/material.dart';

class ProfileSettingsPage extends StatefulWidget {
  final void Function(bool isDark) onThemeChanged;

  const ProfileSettingsPage({super.key, required this.onThemeChanged});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  double maxDistance = 50;
  RangeValues ageRange = const RangeValues(25, 35);
  bool darkMode = false;

  final Map<String, bool> sharedContent = {
    "Photos": true,
    "Bio": true,
    "School": false,
    "Work": false,
    "Facebook": true,
    "Instagram": true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Discovery",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 📍 Location (statique ici)
            ListTile(
              title: const Text("Location"),
              subtitle: const Text("NY, NY"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            // 📏 Maximum Distance
            ListTile(
              title: const Text("Maximum Distance"),
              subtitle: Slider(
                value: maxDistance,
                min: 10,
                max: 100,
                divisions: 9,
                label: "${maxDistance.toInt()} mi",
                onChanged: (value) => setState(() => maxDistance = value),
              ),
            ),

            // 🙋 Show Me (statique)
            ListTile(
              title: const Text("Show me"),
              subtitle: const Text("Male"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            // 🎂 Age Range
            ListTile(
              title: const Text("Age Range"),
              subtitle: RangeSlider(
                values: ageRange,
                min: 18,
                max: 60,
                divisions: 42,
                labels: RangeLabels(
                  "${ageRange.start.toInt()}",
                  "${ageRange.end.toInt()}",
                ),
                onChanged: (values) => setState(() => ageRange = values),
              ),
            ),

            const Divider(height: 30),
            const Text(
              "Shared Content",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 📤 Contenu partagé (switchs)
            ...sharedContent.entries.map(
              (entry) => SwitchListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged: (value) =>
                    setState(() => sharedContent[entry.key] = value),
              ),
            ),

            const Divider(height: 30),
            // 🌓 Dark Mode
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: darkMode,
              onChanged: (value) {
                setState(() => darkMode = value);
                widget.onThemeChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
