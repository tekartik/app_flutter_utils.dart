import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell_run.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

String buildDatabasesPath(String packageName) {
  var dataPath = join(userAppDataPath, packageName, 'databases');
  try {
    var dir = Directory(dataPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  } catch (_) {}
  return dataPath;
}

/// Workaround for flutter test (no path_provider there)
bool get _inFlutterTest => Platform.environment['FLUTTER_TEST'] == 'true';

/// Where the sqflite plugin kept the databases, before the switch to ffi:
/// `<dataDir>/databases` on Android, the documents directory on iOS and
/// macOS.
Future<String> _sqflitePluginDatabasesPath() async {
  if (Platform.isAndroid) {
    // <dataDir>/files
    var filesDir = await getApplicationSupportDirectory();
    return join(dirname(filesDir.path), 'databases');
  }
  return (await getApplicationDocumentsDirectory()).path;
}

/// The ffi factory with its databases path set (once, before the first call)
/// to the sqflite plugin location, so that relative database names resolve
/// where the existing data is.
///
/// Left alone, ffi resolves them against `.dart_tool` in the current
/// directory, which is `/` in an Android, iOS or macOS app: nothing opens.
class _AppDatabaseFactory implements DatabaseFactory {
  final DatabaseFactory _delegate;

  _AppDatabaseFactory(this._delegate);

  late final Future<void> _ready = () async {
    try {
      await _delegate.setDatabasesPath(await _sqflitePluginDatabasesPath());
    } catch (e) {
      // Keep the ffi default
      stderr.writeln('tekartik_app_flutter_sqflite: no databases path ($e)');
    }
  }();

  @override
  Future<Database> openDatabase(
    String path, {
    OpenDatabaseOptions? options,
  }) async {
    await _ready;
    return _delegate.openDatabase(path, options: options);
  }

  @override
  Future<String> getDatabasesPath() async {
    await _ready;
    return _delegate.getDatabasesPath();
  }

  @override
  Future<void> setDatabasesPath(String path) async {
    // After the default one, not overwritten by it
    await _ready;
    await _delegate.setDatabasesPath(path);
  }

  @override
  Future<void> deleteDatabase(String path) async {
    await _ready;
    await _delegate.deleteDatabase(path);
  }

  @override
  Future<bool> databaseExists(String path) async {
    await _ready;
    return _delegate.databaseExists(path);
  }

  @override
  Future<void> writeDatabaseBytes(String path, Uint8List bytes) async {
    await _ready;
    await _delegate.writeDatabaseBytes(path, bytes);
  }

  @override
  Future<Uint8List> readDatabaseBytes(String path) async {
    await _ready;
    return _delegate.readDatabaseBytes(path);
  }
}

final DatabaseFactory _defaultDatabaseFactory =
    ((Platform.isAndroid || Platform.isIOS || Platform.isMacOS) &&
        !_inFlutterTest)
    ? _AppDatabaseFactory(databaseFactoryFfi)
    : databaseFactoryFfi;

/// All but Linux/Windows
DatabaseFactory get databaseFactory => _defaultDatabaseFactory;

/// Use sqflite on any platform
Future<DatabaseFactory> initDatabaseFactory(String packageName) async {
  if (Platform.isLinux || Platform.isWindows) {
    var databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(buildDatabasesPath(packageName));
    return databaseFactory;
  } else {
    return databaseFactory;
  }
}

/// Use sqflite on any platform
DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) {
  if (Platform.isLinux || Platform.isWindows) {
    var databaseFactory = databaseFactoryFfi;
    // Should not return a future...or ignore
    databaseFactory.setDatabasesPath(
      rootPath ?? buildDatabasesPath(packageName ?? '.'),
    );
    return databaseFactory;
  } else {
    return databaseFactory;
  }
}

void sqfliteWindowsFfiInit() => sqfliteFfiInit();
