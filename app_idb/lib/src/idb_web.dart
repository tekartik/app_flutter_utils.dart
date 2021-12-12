import 'package:idb_shim/idb_shim.dart';

IdbFactory get idbFactory => idbFactoryNative;

IdbFactory getIdbFactory({String? packageName}) => idbFactory;
