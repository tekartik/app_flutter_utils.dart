// A desktop app that reopens at its last size, shows its size and toggles
// full screen on a tap. On the web, mobile and under flutter test there is no
// app window: appWindowCurrent() is null and the keeper does nothing.
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_window/app_window.dart';
import 'package:tekartik_prefs/prefs_light.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // In memory here: an app uses a persistent store, such as
  // getPrefsLightSdb(sdbFactory).kvStore of tekartik_prefs_sdb.
  var store = PrefsMemory().kvStore;
  var keeper = AppWindowSizeKeeper(
    store: store,
    minimumSize: const Size(400, 300),
  );
  // Before runApp: the window opens at its last size.
  await keeper.restoreAppWindow();

  // Kept for the life of the app.
  var window = appWindowCurrent();
  if (window != null) {
    try {
      window.title = 'app_window example';
    } catch (_) {
      // A window issue must never prevent the app from starting.
    }
    // Asked when the user closes the window: ask the user here.
    window.closeRequestHandler = () async => true;
  }
  runApp(
    AppWindowSizeSaver(
      keeper: keeper,
      window: window,
      child: ExampleApp(window: window),
    ),
  );
}

const _textStyle = TextStyle(color: Color(0xFF000000), fontSize: 20);

/// Shows the window size, a tap toggles full screen.
class ExampleApp extends StatelessWidget {
  /// The app window, null when there is none.
  final AppWindow? window;

  /// Example app.
  const ExampleApp({super.key, required this.window});

  @override
  Widget build(BuildContext context) {
    var window = this.window;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFFFFFFFF),
        child: Center(
          child: window == null
              ? const Text('No app window here', style: _textStyle)
              : GestureDetector(
                  onTap: () => window.isFullScreen = !window.isFullScreen,
                  child: StreamBuilder<Size>(
                    stream: window.onResized,
                    initialData: window.size,
                    builder: (context, snapshot) => Text(
                      '${snapshot.data} (tap: full screen)',
                      style: _textStyle,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
