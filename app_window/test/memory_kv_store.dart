import 'package:tekartik_app_flutter_window/app_window.dart';

/// A [KvStore] in a map ([map], a new one by default).
KvStore memoryKvStore([Map<String, String>? map]) {
  var values = map ?? <String, String>{};
  return KvStore(
    getString: (key) async => values[key],
    setString: (key, value) async => values[key] = value,
    remove: (key) async => values.remove(key),
  );
}
