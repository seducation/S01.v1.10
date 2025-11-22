import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/profile');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.shield_outlined),
                      title: const Text('App Permission'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_app_permission'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Dark Mode'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Dark Mode'),
                              content: Consumer<ThemeModel>(
                                builder: (context, themeModel, child) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: const Text('Light'),
                                        onTap: () {
                                          themeModel.themeMode = ThemeMode.light;
                                          Navigator.of(context).pop();
                                        },
                                        trailing: themeModel.themeMode == ThemeMode.light
                                            ? const Icon(Icons.check)
                                            : null,
                                      ),
                                      ListTile(
                                        title: const Text('Dark'),
                                        onTap: () {
                                          themeModel.themeMode = ThemeMode.dark;
                                          Navigator.of(context).pop();
                                        },
                                        trailing: themeModel.themeMode == ThemeMode.dark
                                            ? const Icon(Icons.check)
                                            : null,
                                      ),
                                      ListTile(
                                        title: const Text('System'),
                                        onTap: () {
                                          themeModel.themeMode = ThemeMode.system;
                                          Navigator.of(context).pop();
                                        },
                                        trailing: themeModel.themeMode == ThemeMode.system
                                            ? const Icon(Icons.check)
                                            : null,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.color_lens_outlined),
                      title: const Text('Theme'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_theme'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Location'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_location'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.online_prediction_outlined),
                      title: const Text('Active Status'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_active_status'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Personal Info'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_personal_info'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_privacy'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.safety_check_outlined),
                      title: const Text('Safety'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_safety'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_delete'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.support_agent_outlined),
                      title: const Text('Support'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_support'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.emergency_outlined),
                      title: const Text('Emergency'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/setting_emergency'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
