import 'package:idb_shim/sdb.dart';

/// Value comparison of the arguments of the sdb list views.
///
/// The views are usually built with arguments created inline
/// (`SdbFindOptions(...)`, `store.asJoinTarget`, `store.asJoinSourceAt(...)`),
/// i.e. new objects on every build. Comparing them by identity would recreate
/// the owned controller (reloading the list and losing the scroll position)
/// on any unrelated parent rebuild.

/// True if [a] and [b] are the same index of the same store.
bool sdbIndexRefEquals(SdbIndexRef? a, SdbIndexRef? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  return a.runtimeType == b.runtimeType &&
      a.store == b.store &&
      a.name == b.name;
}

/// True if [a] and [b] describe the same filter.
///
/// Filters have no value equality, their description is compared instead.
/// A custom filter (a closure) is only equal to itself.
bool sdbFilterEquals(SdbFilter? a, SdbFilter? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  var text = a.toString();
  return a.runtimeType == b.runtimeType &&
      !text.contains('SembastCustomFilter') &&
      text == b.toString();
}

/// True if [a] and [b] select the same records.
bool sdbFindOptionsEquals(SdbFindOptions? a, SdbFindOptions? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  return a.boundaries == b.boundaries &&
      a.limit == b.limit &&
      a.offset == b.offset &&
      a.descending == b.descending &&
      sdbFilterEquals(a.filter, b.filter);
}

/// True if [a] and [b] iterate the same records with the same join key.
bool sdbJoinSourceEquals(SdbJoinSource? a, SdbJoinSource? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  return a.runtimeType == b.runtimeType &&
      a.store == b.store &&
      sdbIndexRefEquals(a.index, b.index) &&
      a.joinKeyPath == b.joinKeyPath;
}

/// True if [a] and [b] match the join key against the same records.
bool sdbJoinTargetEquals(SdbJoinTarget? a, SdbJoinTarget? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  return a.runtimeType == b.runtimeType &&
      a.store == b.store &&
      sdbIndexRefEquals(a.index, b.index);
}

/// True if [a] and [b] join the same way (null being the default options).
bool sdbJoinFindOptionsEquals(SdbJoinFindOptions? a, SdbJoinFindOptions? b) {
  var optionsA = a ?? sdbJoinFindOptionsDefault;
  var optionsB = b ?? sdbJoinFindOptionsDefault;
  return optionsA.distinct == optionsB.distinct &&
      optionsA.inner == optionsB.inner &&
      optionsA.chunkSize == optionsB.chunkSize;
}
