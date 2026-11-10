// Three links: a web page (a new tab on the web), a mail and a phone number.
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_url_launcher_flutter/web_launch_uri.dart';

/// The links of the page, with their uri built by `Uri` (encoded).
final links = <String, Uri>{
  'Online help': Uri.https('example.com', '/help', {'from': 'example'}),
  'Send feedback': Uri(
    scheme: 'mailto',
    path: 'feedback@example.com',
    queryParameters: {'subject': 'Hello'},
  ),
  'Call us': Uri(scheme: 'tel', path: '+33123456789'),
};

/// The page, [launch] injected (tests pass a recording function).
class LinksPage extends StatelessWidget {
  /// Opens a uri.
  final void Function(Uri uri) launch;

  /// The page.
  const LinksPage({super.key, this.launch = webLaunchUri});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var entry in links.entries)
          GestureDetector(
            // Synchronous, straight from the gesture (web popup blocker).
            onTap: () => launch(entry.value),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(entry.key),
            ),
          ),
      ],
    );
  }
}

void main() {
  runApp(
    const Directionality(textDirection: TextDirection.ltr, child: LinksPage()),
  );
}
