import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme_model.dart';

class SettingThemeScreen extends StatefulWidget {
  const SettingThemeScreen({super.key});

  @override
  State<SettingThemeScreen> createState() => _SettingThemeScreenState();
}

enum ThemeOptions { light, dark, system }

class _SettingThemeScreenState extends State<SettingThemeScreen> {
  ThemeOptions _selectedTheme = ThemeOptions.system;
  bool _isScheduled = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 0);

  Future<void> _selectTime(BuildContext context,
      {required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildThemeSection(),
          const SizedBox(height: 24),
          _buildBackgroundColorSection(),
          const SizedBox(height: 24),
          _buildAppIconSection(),
          const SizedBox(height: 24),
          _buildScheduleSection(),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeOptions>(
              segments: const [
                ButtonSegment(value: ThemeOptions.light, label: Text('Light')),
                ButtonSegment(value: ThemeOptions.dark, label: Text('Dark')),
                ButtonSegment(
                    value: ThemeOptions.system, label: Text('System')),
              ],
              selected: {_selectedTheme},
              onSelectionChanged: (Set<ThemeOptions> newSelection) {
                setState(() {
                  _selectedTheme = newSelection.first;
                });
                // Update the ThemeModel
                final themeModel = context.read<ThemeModel>();
                ThemeMode mode;
                switch (_selectedTheme) {
                  case ThemeOptions.light:
                    mode = ThemeMode.light;
                    break;
                  case ThemeOptions.dark:
                    mode = ThemeMode.dark;
                    break;
                  case ThemeOptions.system:
                    mode = ThemeMode.system;
                    break;
                }
                themeModel.themeMode = mode;
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                selectedBackgroundColor: Colors.blue,
                selectedForegroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundColorSection() {
    final themeModel = context.watch<ThemeModel>();
    final List<Color> presetColors = [
      Colors.white,
      Colors.black,
      const Color(0xFF121212), // Dark Grey
      Colors.blueGrey,
      const Color(0xFFE0F7FA), // Cyan accent
      const Color(0xFFFFF8E1), // Amber accent
      const Color(0xFFF3E5F5), // Purple accent
      const Color(0xFFE8F5E9), // Green accent
      const Color(0xFF1A237E), // Deep Blue
      const Color(0xFF311B92), // Deep Purple
    ];

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Background Color',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    themeModel.resetBackgroundColor();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: presetColors.map((color) {
                final isSelected = themeModel.customBackgroundColor == color;
                return GestureDetector(
                  onTap: () {
                    themeModel.customBackgroundColor = color;
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIconSection() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        title: const Text('Change app icon'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to app icon selection screen
        },
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [
          ListTile(
            title: const Text('Schedule'),
            trailing: Switch(
              value: _isScheduled,
              onChanged: (bool value) {
                setState(() {
                  _isScheduled = value;
                });
              },
            ),
          ),
          if (_isScheduled)
            Column(
              children: [
                ListTile(
                  title: const Text('Start time'),
                  trailing: Text(_startTime.format(context)),
                  onTap: () => _selectTime(context, isStart: true),
                ),
                ListTile(
                  title: const Text('End time'),
                  trailing: Text(_endTime.format(context)),
                  onTap: () => _selectTime(context, isStart: false),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
