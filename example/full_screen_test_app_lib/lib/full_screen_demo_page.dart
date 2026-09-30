import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';

/// Shows the platform full screen state and lets the user change it.
///
/// The app bar goes away while full screen (the app's own full screen),
/// the platform step is [PlatformFullScreen].
class FullScreenDemoPage extends StatefulWidget {
  /// The platform full screen, created (and disposed) here when null.
  final PlatformFullScreen? fullScreen;

  /// Demo page, [fullScreen] injected in tests.
  const FullScreenDemoPage({super.key, this.fullScreen});

  @override
  State<FullScreenDemoPage> createState() => _FullScreenDemoPageState();
}

class _FullScreenDemoPageState extends State<FullScreenDemoPage> {
  late final PlatformFullScreen _fullScreen;
  late final bool _ownsFullScreen;
  StreamSubscription<bool>? _subscription;
  final _events = <String>[];

  @override
  void initState() {
    super.initState();
    _ownsFullScreen = widget.fullScreen == null;
    _fullScreen = widget.fullScreen ?? createPlatformFullScreen();
    _subscription = _fullScreen.onChanged.listen((isFullScreen) {
      setState(() {
        _events.add('onChanged: $isFullScreen');
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_ownsFullScreen) {
      // Give the screen back, then release.
      _fullScreen.setFullScreen(false);
      _fullScreen.dispose();
    }
    super.dispose();
  }

  Future<void> _set(bool fullScreen) async {
    // Synchronous call from the gesture: the browser refuses otherwise.
    await _fullScreen.setFullScreen(fullScreen);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggle() async {
    await _fullScreen.toggleFullScreen();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var isFullScreen = _fullScreen.isFullScreen;
    return Scaffold(
      appBar: isFullScreen
          ? null
          : AppBar(title: const Text('Platform full screen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('supported: ${_fullScreen.supported}'),
          Text('isFullScreen: $isFullScreen'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                onPressed: () => _set(true),
                child: const Text('Enter'),
              ),
              FilledButton(
                onPressed: () => _set(false),
                child: const Text('Exit'),
              ),
              FilledButton(onPressed: _toggle, child: const Text('Toggle')),
              if (isFullScreen)
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Events (escape or F11 show up here too):'),
          for (var event in _events) Text(event),
        ],
      ),
    );
  }
}
