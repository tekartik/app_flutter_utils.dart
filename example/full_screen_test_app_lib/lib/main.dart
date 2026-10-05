import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_dev_menu_flutter/dev_menu_flutter.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_full_screen_test_app_lib/full_screen_demo_page.dart';

export 'full_screen_demo_page.dart';

/// The full screen test menu: the raw api, and the demo page.
void defineMenu() {
  menu('full_screen', () {
    PlatformFullScreen? fullScreen;
    PlatformFullScreen get() {
      return fullScreen ??= createPlatformFullScreen()
        ..onChanged.listen((isFullScreen) {
          write('onChanged: $isFullScreen');
        });
    }

    item('supported', () {
      write('supported: ${get().supported}');
    });
    item('isFullScreen', () {
      write('isFullScreen: ${get().isFullScreen}');
    });
    item('setFullScreen(true)', () async {
      await get().setFullScreen(true);
      write('isFullScreen: ${get().isFullScreen}');
    });
    item('setFullScreen(false)', () async {
      await get().setFullScreen(false);
      write('isFullScreen: ${get().isFullScreen}');
    });
    item('toggleFullScreen', () async {
      await get().toggleFullScreen();
      write('isFullScreen: ${get().isFullScreen}');
    });
    item('dispose', () {
      fullScreen?.dispose();
      fullScreen = null;
      write('disposed');
    });
    item('demo page', () async {
      await navigator.push<void>(
        MaterialPageRoute(builder: (_) => const FullScreenDemoPage()),
      );
    });
  });
}

void main() {
  platformInit();
  mainMenuFlutter(() {
    defineMenu();
  }, showConsole: true);
}
