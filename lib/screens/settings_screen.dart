import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(),
        builder: (context, Box box, _) {
          final String currentTheme = box.get(
            'themeMode',
            defaultValue: 'System',
          );
          final String dashboardTimeframe = box.get(
            'dashboardTimeframe',
            defaultValue: 'Lifetime',
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, 'Appearance'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('System Default'),
                      value: 'System',
                      groupValue: currentTheme,
                      onChanged: (val) => box.put('themeMode', val),
                    ),
                    RadioListTile<String>(
                      title: const Text('Light Mode'),
                      value: 'Light',
                      groupValue: currentTheme,
                      onChanged: (val) => box.put('themeMode', val),
                    ),
                    RadioListTile<String>(
                      title: const Text('Dark Mode'),
                      value: 'Dark',
                      groupValue: currentTheme,
                      onChanged: (val) => box.put('themeMode', val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'Dashboard Preferences'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: const Text('Default Timeframe'),
                  subtitle: const Text(
                    'Choose what total display on dashboard',
                  ),
                  trailing: DropdownButton<String>(
                    value: dashboardTimeframe,
                    underline: const SizedBox(),
                    onChanged: (val) {
                      if (val != null) box.put('dashboardTimeframe', val);
                    },
                    items: ['Lifetime', 'This Year', 'This Month'].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
