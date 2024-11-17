import 'package:flutter/material.dart';
import 'package:gandalf/Utils.dart';
import 'package:gandalf/constants.dart';
import 'package:gandalf/widgets/Buttons/Alpha.dart';
import 'package:share_plus/share_plus.dart';

const YOUTUBE_LINK = 'https://youtu.be/BBGEG21CGo0';

class SheetContent extends StatelessWidget {
  const SheetContent({Key? key}) : super(key: key);

  void _shareContent() {
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
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // YouTube Button
              AlphaButton(
                onTap: () => Utils.launchUrl(YOUTUBE_LINK),
                label: 'Original video',
                icon: Icons.play_circle_filled,
                color: Colors.red.withOpacity(0.1),
              ),

              SizedBox(height: PADDING),

              // Share Button
              AlphaButton(
                onTap: _shareContent,
                label: 'Share',
                icon: Icons.share,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
