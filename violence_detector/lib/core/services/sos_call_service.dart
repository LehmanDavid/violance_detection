import 'package:url_launcher/url_launcher.dart';

final class SOSCallService {
  static Future<void> launchDialer() async {
    final url = Uri.parse("tel:112");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Application unable to open dialer.';
    }
  }
}
