import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tekartik_prefs_flutter/prefs.dart';
import 'package:tekartik_prefs_sembast/prefs.dart';

import 'import.dart';

PrefsFactory get prefsFactory => prefsFactoryFlutter;

final _prefsFactoryMap = <String?, PrefsFactory>{};

PrefsFactory newPrefsFactorySembast(String? packageName) {
  var dataPath =
      join(userAppDataPath, packageName ?? 'com.tekartik.app_prefs', 'prefs');
  try {
    Directory(dirname(dataPath)).createSync(recursive: true);
  } catch (_) {}
  return getPrefsFactorySembast(databaseFactoryIo, dataPath);
}

/// Use sembast on linux and windows
PrefsFactory getPrefsFactory({String? packageName}) {
  if (Platform.isLinux || Platform.isWindows) {
    var prefsFactory = _prefsFactoryMap[packageName];
    if (prefsFactory == null) {
      _prefsFactoryMap[packageName] =
          prefsFactory = newPrefsFactorySembast(packageName);
    }
    return prefsFactory;
  } else {
    return prefsFactory;
  }
}
