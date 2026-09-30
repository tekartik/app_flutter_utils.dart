import 'full_screen.dart';

/// In-memory [PlatformFullScreen]: no platform, the state follows the
/// requests, every request is recorded in [requests].
///
/// For widget tests and previews; [simulateFullScreenChanged] plays a change
/// not asked for (escape in the browser).
class PlatformFullScreenMemory extends PlatformFullScreenBase {
  @override
  final bool supported;

  /// Every [setFullScreen] argument, in order, whether [supported] or not.
  final requests = <bool>[];

  /// Supported by default; an unsupported one records the requests and
  /// never changes state.
  PlatformFullScreenMemory({this.supported = true});

  @override
  Future<void> setFullScreen(bool fullScreen) async {
    requests.add(fullScreen);
    if (supported) {
      setFullScreenState(fullScreen);
    }
  }

  /// A change made by the platform, not by the app: updates [isFullScreen]
  /// and emits [onChanged] when it differs.
  void simulateFullScreenChanged(bool fullScreen) =>
      setFullScreenState(fullScreen);
}
