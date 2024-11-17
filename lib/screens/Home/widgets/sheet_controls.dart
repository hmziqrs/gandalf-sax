import 'package:flutter/material.dart';
import 'package:gandalf/constants.dart';
import 'package:gandalf/providers/app.dart';
import 'package:gandalf/widgets/Buttons/Alpha.dart';

class SheetControls extends StatelessWidget {
  const SheetControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = AppProvider.of(context, true);

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
                  onTap: () => appProvider.setThemeMode(ThemeMode.light),
                  margin: EdgeInsets.only(right: PADDING),
                  icon: Icons.light_mode,
                ),
              ),
              Expanded(
                child: AlphaButton(
                  label: 'Dark',
                  onTap: () => appProvider.setThemeMode(ThemeMode.dark),
                  margin: EdgeInsets.symmetric(horizontal: PADDING),
                  icon: Icons.dark_mode,
                ),
              ),
              Expanded(
                child: AlphaButton(
                  label: 'System',
                  onTap: () => appProvider.setThemeMode(ThemeMode.system),
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
                value: appProvider.backgroundPlayback,
                onChanged: (value) => appProvider.setBackgroundPlayback(value),
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
            'Theme: ${appProvider.themeMode.toString().split('.').last}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Background Playback: ${appProvider.backgroundPlayback ? 'Enabled' : 'Disabled'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
