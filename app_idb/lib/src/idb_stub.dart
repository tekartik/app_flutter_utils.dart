import 'package:idb_shim/idb_shim.dart';

IdbFactory get idbFactory => _stub('idbFactory');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
