import 'package:flutter/material.dart';
import 'package:gandalf/Utils.dart';
import 'package:gandalf/constants.dart';
import 'package:gandalf/screens/Home/events.dart';
import 'package:gandalf/services/analytics.dart';
import 'package:gandalf/widgets/Buttons/Alpha.dart';
import 'package:gandalf/widgets/banner_ad.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const YOUTUBE_LINK = 'https://youtu.be/BBGEG21CGo0';

const USER = "hmziqrs";

final links = [
  {
    "icon": FontAwesomeIcons.globe,
    "label": "hmziq.rs",
    "url": "https://hmziq.rs",
  },
  {
    "icon": FontAwesomeIcons.github,
    "url": "https://github.com/$USER",
    "label": "@$USER",
  },
  {
    "icon": FontAwesomeIcons.xTwitter,
    "url": "https://x.hmziq.rs",
    "label": "$USER",
  }
];

class SheetContent extends StatelessWidget {
  const SheetContent({Key? key}) : super(key: key);

  void _shareContent() {
    Analytics.logEvent(ShareContentEvent());
    Share.share(
      'Check out Epic Sax Gandalf: $YOUTUBE_LINK',
      subject: 'Epic Sax Gandalf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PADDING * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Behold the glory of infinite Gadalf!",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            "Billions must be entertained!",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          SizedBox(height: PADDING * 2),
          AppBannerAd(),
          Text(
            "Developer: $USER",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: PADDING * 1),
          Wrap(
            spacing: PADDING * 1.5,
            runSpacing: PADDING * 1.5,
            children: links
                .map(
                  (link) => AlphaButton(
                    onTap: () {
                      Analytics.logEvent(
                        ClickSocialLinkEvent(
                          platform: link['label']! as String,
                          url: link['url']! as String,
                        ),
                      );

                      Utils.launchUrl(link['url']! as String);
                    },
                    icon: link['icon']! as IconData,
                    label: link['label']! as String,
                  ),
                )
                .toList(),
          ),
          SizedBox(height: PADDING * 3),
          Text(
            "Video source:",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: PADDING * 1),
          Row(
            children: [
              // YouTube Button
              AlphaButton(
                onTap: () => Utils.launchUrl(YOUTUBE_LINK),
                label: 'Original video',
                icon: Icons.play_circle_filled,
              ),

              SizedBox(width: PADDING * 1.5),

              // Share Button
              AlphaButton(
                onTap: _shareContent,
                icon: Icons.share,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
