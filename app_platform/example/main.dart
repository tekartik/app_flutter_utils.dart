// Shows where the app runs: the io platform (Android, iOS, macOS, Linux,
// Windows) or the browser, and the platform context map.
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_platform/platform.dart' as p;

/// A one line description of the platform.
String describePlatform() {
  var io = platformContext.io;
  if (io != null) {
    var os = p.isAndroid
        ? 'Android'
        : p.isIOS
        ? 'iOS'
        : p.isMacOS
        ? 'macOS'
        : p.isLinux
        ? 'Linux'
        : p.isWindows
        ? 'Windows'
        : 'io';
    return 'App on $os';
  }
  var browser = platformContext.browser!;
  // On the web the os is the browser's (an Android phone or tablet).
  var android = browser.os.isAndroid ? ' on Android' : '';
  return 'Web app${browser.isChrome ? ' in Chrome' : ''}$android';
}

void main() {
  platformInit(); // A no-op today, harmless.
  runApp(
    Center(
      child: Text(
        '${describePlatform()}\n${platformContext.toMap()}',
        textDirection: TextDirection.ltr,
      ),
    ),
  );
}
