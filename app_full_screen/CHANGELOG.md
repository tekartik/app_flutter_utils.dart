## 0.1.1

- `window_manager` >= 0.6.0 (nativeapi): the app window through
  `WindowManager.instance.getCurrent()`, its full screen events instead of
  the 0.5.x `WindowListener`.

## 0.1.0

- Initial version: `PlatformFullScreen` (supported, isFullScreen, onChanged,
  setFullScreen, toggleFullScreen, dispose) created by
  `createPlatformFullScreen()`: browser full screen api on the web (through
  `tekartik_browser_utils`), `window_manager` on Linux, macOS and Windows,
  `SystemChrome` immersive mode on Android and iOS, unsupported elsewhere.
  `PlatformFullScreenMemory` for tests. Extracted from playelio.
