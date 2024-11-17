import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/constants.dart';
import 'package:gandalf/providers/app.dart';
import 'package:gandalf/widgets/Buttons/Alpha.dart';

class SheetControls extends ConsumerWidget {
  const SheetControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> themeButtons = const [
      {
        'label': 'Light',
        'mode': ThemeMode.light,
        'icon': Icons.light_mode,
      },
      {
        'label': 'Dark',
        'mode': ThemeMode.dark,
        'icon': Icons.dark_mode,
      },
      {
        'label': 'System',
        'mode': ThemeMode.system,
        'icon': Icons.settings_brightness,
      },
    ];

    final appState = ref.watch(appSettingsProvider);
    final appController = ref.read(appSettingsProvider.notifier);
    final isNarrow = MediaQuery.of(context).size.width < 480;
    print("${appState.themeMode}");

    return Padding(
      padding: const EdgeInsets.all(PADDING * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Theme Selection
          Text(
            'Theme',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: PADDING),
          // Theme Buttons
          isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: themeButtons
                      .map((button) => Padding(
                            padding: EdgeInsets.only(bottom: PADDING),
                            child: AlphaButton(
                              label: button['label'],
                              onTap: () =>
                                  appController.setThemeMode(button['mode']),
                              icon: button['icon'],
                              color: appState.themeMode == button['mode']
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2)
                                  : null,
                            ),
                          ))
                      .toList(),
                )
              : Row(
                  children: themeButtons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final button = entry.value;

                    return Expanded(
                      child: AlphaButton(
                        label: button['label'],
                        onTap: () => appController.setThemeMode(button['mode']),
                        margin: EdgeInsets.only(
                          left: index == 0 ? 0 : PADDING,
                          right: index == themeButtons.length - 1 ? 0 : PADDING,
                        ),
                        icon: button['icon'],
                        color: appState.themeMode == button['mode']
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : null,
                      ),
                    );
                  }).toList(),
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
                    appController.setBackgroundPlayback(
                  value,
                ),
              ),
            ],
          ),
          SizedBox(height: PADDING * 1),
        ],
      ),
    );
  }
}
