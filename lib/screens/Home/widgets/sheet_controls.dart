import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/constants.dart';
import 'package:gandalf/providers/app.dart';
import 'package:gandalf/widgets/Buttons/Alpha.dart';

class SheetControls extends ConsumerWidget {
  const SheetControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appSettingsProvider);
    final appController = ref.read(appSettingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(PADDING * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: PADDING * 3),

          // Theme Selection
          Text(
            'Theme',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: PADDING),
          Row(
            children: [
              Expanded(
                child: AlphaButton(
                  label: 'Light',
                  onTap: () => appController.setThemeMode(ThemeMode.light),
                  margin: EdgeInsets.only(right: PADDING),
                  icon: Icons.light_mode,
                ),
              ),
              Expanded(
                child: AlphaButton(
                  label: 'Dark',
                  onTap: () => appController.setThemeMode(ThemeMode.dark),
                  margin: EdgeInsets.symmetric(horizontal: PADDING),
                  icon: Icons.dark_mode,
                ),
              ),
              Expanded(
                child: AlphaButton(
                  label: 'System',
                  onTap: () => appController.setThemeMode(ThemeMode.system),
                  margin: EdgeInsets.only(left: PADDING),
                  icon: Icons.settings_brightness,
                ),
              ),
            ],
          ),
          SizedBox(height: PADDING * 3),

          // Background Playback Toggle
          Row(
            children: [
              Expanded(
                child: Text(
                  'Background Playback',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch(
                value: appState.backgroundPlayback,
                onChanged: (value) =>
                    appController.setBackgroundPlayback(value),
              ),
            ],
          ),

          // Current Settings Status
          SizedBox(height: PADDING * 3),
          Text(
            'Current Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: PADDING),
          Text(
            'Theme: ${appState.themeMode.toString().split('.').last}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Background Playback: ${appState.backgroundPlayback ? 'Enabled' : 'Disabled'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
