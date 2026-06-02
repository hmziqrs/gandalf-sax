import 'package:gandalf/services/analytics.dart';

class ViewHomeScreenEvent implements AnalyticsEvent {
  @override
  String get eventName => 'view_home_screen';

  @override
  Map<String, Object> get parameters => {};
}

class OpenSheetEvent implements AnalyticsEvent {
  @override
  String get eventName => 'open_sheet';

  @override
  Map<String, Object> get parameters => {};
}

class ShareContentEvent implements AnalyticsEvent {
  @override
  String get eventName => 'share_content';

  @override
  Map<String, Object> get parameters => {};
}

class ChangeThemeEvent implements AnalyticsEvent {
  final String mode;

  ChangeThemeEvent(this.mode);

  @override
  String get eventName => 'change_theme';

  @override
  Map<String, Object> get parameters => {
        'theme_mode': mode,
      };
}

class ToggleBackgroundPlaybackEvent implements AnalyticsEvent {
  final bool enabled;

  ToggleBackgroundPlaybackEvent(this.enabled);

  @override
  String get eventName => 'toggle_background_playback';

  @override
  Map<String, Object> get parameters => {
        'enabled': enabled,
      };
}

class ClickSocialLinkEvent implements AnalyticsEvent {
  final String platform;
  final String url;

  ClickSocialLinkEvent({
    required this.platform,
    required this.url,
  });

  @override
  String get eventName => 'click_social_link';

  @override
  Map<String, Object> get parameters => {
        'platform': platform,
        'url': url,
      };
}
