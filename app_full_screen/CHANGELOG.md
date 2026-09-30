## 0.1.0

- Initial version: `PlatformFullScreen` (supported, isFullScreen, onChanged,
  setFullScreen, toggleFullScreen, dispose) created by
  `createPlatformFullScreen()`: browser full screen api on the web (through
  `tekartik_browser_utils`), `window_manager` on Linux, macOS and Windows,
  `SystemChrome` immersive mode on Android and iOS, unsupported elsewhere.
  `PlatformFullScreenMemory` for tests. Extracted from playelio.
