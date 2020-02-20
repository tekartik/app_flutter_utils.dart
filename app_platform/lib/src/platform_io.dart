import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tekartik_platform_io/context_io.dart';
import 'package:tekartik_platform/context.dart' show PlatformContext;

void platformInit() {
  // No need to handle macOS, as it has now been added to TargetPlatform.
  if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

PlatformContext get platformContext => platformContextIo;
