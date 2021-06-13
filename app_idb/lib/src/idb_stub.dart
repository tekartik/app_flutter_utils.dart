import 'package:idb_shim/idb_shim.dart';

IdbFactory get idbFactory => _stub('idbFactory');

IdbFactory getIdbFactory({String? packageName}) =>
    _stub('getIdbFactory($packageName)');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
