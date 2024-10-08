import 'package:dev_build/package.dart';
import 'package:path/path.dart';

Future main() async {
  for (var dir in [
    'app_intl',
    'app_firebase_storage',
    'app_widget',
    'app_bloc',
    'app_rx_bloc',
    'app_fs',
    'test_app',
    'app_emit_builder',
    'app_firebase',
    'app_firebase_auth',
    'app_firebase_firestore',
    'app_plugin',
    'app_idb',
    'app_rx_utils',
    'app_prefs',
    'app_platform',
    'app_roboto',
    'app_sembast',
    'app_lints',
    'app_common',
    join('example', 'test_app')
  ]) {
    await packageRunCi(join('..', dir));
  }
  await packageRunCi('.');
}
