import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_url_launcher_flutter/web_launch_uri.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/link.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Records the launches, fails as url_launcher_android does when no app
/// handles the uri when [noActivity] is set.
class _FakeUrlLauncher extends UrlLauncherPlatform {
  final bool noActivity;
  final launches = <(String, String?)>[];

  _FakeUrlLauncher({this.noActivity = false});

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launches.add((url, options.webOnlyWindowName));
    if (noActivity) {
      throw PlatformException(
        code: 'ACTIVITY_NOT_FOUND',
        message: 'No Activity found to handle intent { $url }',
      );
    }
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('webLaunchUri', () {
    late UrlLauncherPlatform previous;
    setUp(() {
      previous = UrlLauncherPlatform.instance;
    });
    tearDown(() {
      UrlLauncherPlatform.instance = previous;
    });

    test('launch in a new tab', () async {
      var launcher = _FakeUrlLauncher();
      UrlLauncherPlatform.instance = launcher;
      webLaunchUri(Uri.parse('https://example.com/help'));
      await pumpEventQueue();
      expect(launcher.launches, [('https://example.com/help', '_blank')]);
    });

    test('no app for the uri: no uncaught error', () async {
      var launcher = _FakeUrlLauncher(noActivity: true);
      UrlLauncherPlatform.instance = launcher;
      // A tablet without phone, no mail app...
      webLaunchUri(Uri.parse('tel:123'));
      await pumpEventQueue();
      expect(launcher.launches, [('tel:123', '_blank')]);
    });
  });
}
