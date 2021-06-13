// Noop
import 'package:tekartik_platform/context.dart' show PlatformContext;
import 'package:tekartik_platform_browser/context_browser.dart';

void platformInit() {}

PlatformContext get platformContext => platformContextBrowser;
