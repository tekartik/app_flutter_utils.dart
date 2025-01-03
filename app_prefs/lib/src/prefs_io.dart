import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tekartik_prefs_flutter/prefs.dart';
import 'package:tekartik_prefs_flutter/prefs_async.dart';
import 'package:tekartik_prefs_sembast/prefs.dart';
import 'package:tekartik_prefs_sembast/prefs_async.dart';

PrefsFactory get prefsFactory => prefsFactoryFlutter;

/// Default for io use a local folder
PrefsAsyncFactory get prefsAsyncFactory => prefsAsyncFactoryFlutter;
final _prefsFactoryMap = <String, PrefsFactory>{};
final _prefsAsyncFactoryMap = <String, PrefsAsyncFactory>{};
PrefsFactory? _defaultPrefsFactory;
PrefsAsyncFactory? _defaultPrefsAsyncFactory;

PrefsFactory newPrefsFactorySembast(String? packageName) {
  var dataPath =
      join(userAppDataPath, packageName ?? 'com.tekartik.app_prefs', 'prefs');
  try {
    Directory(dirname(dataPath)).createSync(recursive: true);
  } catch (_) {}
  return getPrefsFactorySembast(databaseFactoryIo, dataPath);
}

/// Sembast prefs factory
PrefsAsyncFactory newPrefsAsyncFactorySembast({String? packageName}) {
  var dataPath =
      join(userAppDataPath, packageName ?? 'com.tekartik.app_prefs', 'prefs');
  try {
    Directory(dirname(dataPath)).createSync(recursive: true);
  } catch (_) {}

  return getPrefsAsyncFactorySembast(databaseFactoryIo, dataPath);
}

/// Use sembast on linux and windows
PrefsFactory getPrefsFactory({String? packageName}) {
  if (Platform.isLinux || Platform.isWindows) {
    var prefsFactory = _prefsFactoryMap[packageName];
    if (prefsFactory == null) {
      if (packageName == null) {
        return _defaultPrefsFactory ??= newPrefsFactorySembast(packageName);
      } else {
        _prefsFactoryMap[packageName] =
            prefsFactory = newPrefsFactorySembast(packageName);
      }
    }
    return prefsFactory;
  } else {
    return prefsFactory;
  }
}

/// Use sembast on linux and windows
PrefsAsyncFactory getPrefsAsyncFactory({String? packageName}) {
  if (Platform.isLinux || Platform.isWindows) {
    var prefsFactory = _prefsAsyncFactoryMap[packageName];
    if (prefsFactory == null) {
      if (packageName == null) {
        prefsFactory = _defaultPrefsAsyncFactory ??=
            newPrefsAsyncFactorySembast(packageName: packageName);
      } else {
        _prefsAsyncFactoryMap[packageName] = prefsFactory =
            newPrefsAsyncFactorySembast(packageName: packageName);
      }
    }
    return prefsAsyncFactory;
  } else {
    return prefsAsyncFactoryFlutter;
  }
}
