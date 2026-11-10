import 'src/import.dart' show PlatformContext;

import 'src/platform.dart' as src;

export 'src/import.dart' show PlatformContext;

/// Called on start by the tekartik apps; a no-op on every platform today
/// (the Linux/Windows setup it did is no longer needed).
void platformInit() => src.platformInit();

/// Browser or io context: `io` is set on Android, iOS, macOS, Linux and
/// Windows, `browser` on the web.
PlatformContext get platformContext => src.platformContext;
