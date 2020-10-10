import 'package:url_launcher/url_launcher.dart' as url;

class Utils {
  static launchUrl(link) async {
    final bool safeCheck = await url.canLaunch(link);
    if (safeCheck) {
      await url.launch(link);
    }
    return safeCheck;
  }

  static socialLink(username, platform) {
    String base = 'https://';
    final coms = ['facebook', 'instagram', 'dribbble', 'fiverr'];
    final nets = ['behance'];

    if (username == null) {
      return null;
    }

    if (coms.contains(platform)) {
      return "${base + platform}.com/$username";
    } else if (nets.contains(platform)) {
      return "${base + platform}.net/$username";
    } else if (platform == 'skype') {
      return "skype:$username?chat";
    } else if (platform == 'email') {
      return "mailto:$username";
    } else if (platform == 'phone') {
      return "tel:$username";
    } else if (platform == 'whatsapp') {
      return "https://api.whatsapp.com/send?phone=$username";
    } else if (platform == 'linkedin') {
      return "$base/linkedin.com/in/$username";
    }
  }

  static launchSocialLink(username, platform) {
    Utils.launchUrl(Utils.socialLink(username, platform));
  }
}
