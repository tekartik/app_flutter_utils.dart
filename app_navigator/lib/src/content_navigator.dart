import 'package:flutter/foundation.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:tekartik_app_navigator_flutter/route_aware.dart' as route_aware;
import 'package:tekartik_app_navigator_flutter/src/navigator_helper.dart';
import 'package:tekartik_app_navigator_flutter/src/route_aware.dart';

import 'import.dart';

/// Should be false in the future
/// The pre flutter 3.24 way
var contentNavigatorUseOnPopPage = false;

/// To set to true for internal debugging and heavy logs
var contentNavigatorDebug = false; // devWarning(true);

class _ContentPageInStack {
  /// Optional custom transition.
  final TransitionDelegate? transitionDelegate;
  final ContentPathRouteSettings rs;
  final ContentPageDef? def;
  final completer =
      Completer<
        Object?
      >(); // Not async we need the return value in the next sequence to allow popping again

  _ContentPageInStack({
    required this.def,
    required this.rs,
    this.transitionDelegate,
  });

  void dispose() {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  /// Build for navigator
  Page build() {
    // ignore: deprecated_member_use_from_same_package, deprecated_member_use
    var page = def!.builder(rs);
    // Name and arguments must match
    assert(
      page.name == rs.path.toPathString(),
      'name of page must match the content path',
    );
    assert(page.arguments == rs.arguments, 'arguments of page must match');
    // devPrint('build page ${page.key} for $routePath');
    return page;
  }

  @override
  String toString() => rs.toString();
}

/// Main content navigator bloc
class ContentNavigatorBloc extends BaseBloc {
  /// Content navigator object
  final ContentNavigator? contentNavigator;
  ContentRouteInformationParser? _routeInformationParser;
  ContentRouterDelegate? _routerDelegate;

  /// Custom transition delegate
  TransitionDelegate transitionDelegate;

  /// Route aware manager
  ContentNavigatorBloc({
    this.contentNavigator,
    this.transitionDelegate = const DefaultTransitionDelegate(),
  }) {
    /// Check here in debug
    if (isDebug) {
      contentNavigator?.def._check();
    }
  }

  /// Router delegate for MaterialApp.router
  ContentRouterDelegate get routerDelegate =>
      _routerDelegate ??= ContentRouterDelegate(this);

  /// Convenient router config for MaterialApp.router
  RouterConfig<ContentPath> get routerConfig => RouterConfig(
    routerDelegate: routerDelegate,
    routeInformationParser: routeInformationParser,
    routeInformationProvider: PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: Uri.base),
    ),
  );

  /// RouteInformationParser for MaterialApp.router
  ContentRouteInformationParser get routeInformationParser =>
      _routeInformationParser ??= ContentRouteInformationParser(this);

  final _stack = <_ContentPageInStack>[];

  late final RouteAwareManager? _routeAwareManager =
      (contentNavigator?.observers
              ?.where((element) => element == route_aware.routeAwareObserver)
              .isNotEmpty ??
          false)
      ? routeAwareManager
      : null;

  /// Custom transition if any
  @protected
  TransitionDelegate? get currentTransitionDelegate =>
      _currentPageInStack?.transitionDelegate;

  /// Current pages
  Iterable<Page> get currentPages {
    if (_stack.isEmpty) {
      // Create a root if needed
      var pageDef = contentNavigator!.def.defs.first;
      var item = _ContentPageInStack(
        def: pageDef,
        rs: ContentPathRouteSettings(pageDef.path),
      );
      _stack.add(item);
    }
    // devPrint(_stack);
    return _stack.map((e) => e.build());
  }

  /// Temp
  @visibleForTesting
  late ChangeNotifier changeNotifier;

  _ContentPageInStack? get _currentPageInStack =>
      _stack.isEmpty ? null : _stack.last;

  /// Current route path.
  ContentPathRouteSettings? get currentRoutePath => _currentPageInStack?.rs;

  /// Current path.
  ContentPath? get currentPath => currentRoutePath?.path;

  void _removeItem(int index) {
    var item = _stack[index];
    item.dispose();
    _stack.removeAt(index);
  }

  void _notifyNavigatorChanges() {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    changeNotifier.notifyListeners();
  }

  // TODO @alex remove call to notify listener
  Future<T> _push<T>(
    ContentPathRouteSettings rs, {
    TransitionDelegate? transitionDelegate,
  }) async {
    // devPrint('Changed $routePath');

    var pageDef = contentNavigator!.def.findPageDef(rs.path);
    if (contentNavigatorDebug) {
      _log('found: $pageDef');
    }
    if (pageDef == null) {
      throw StateError('No page found for route settings ${rs.path}');
    }

    // Find in stack, if found remove
    for (var i = _stack.length - 1; i >= 0; i--) {
      var item = _stack[i];
      if (item.rs.path == rs.path) {
        transientPopItem(i, null);
      }
    }
    var item = _ContentPageInStack(
      def: pageDef,
      rs: rs,
      transitionDelegate: transitionDelegate,
    );
    _stack.add(item);
    _notifyNavigatorChanges();
    // TODO handled future completion

    // TODO wait for pop...
    return await item.completer.future as T;
  }

  /*
  void transientPop([Object? result]) {
    if (_stack.isNotEmpty) {
      transientPopItem(_stack.length - 1, result);
    }
  }*/
  /// Pop until a matching path or push it
  void popUntilPathOrPush(
    BuildContext context,
    ContentPath path, {
    TransitionDelegate? transitionDelegate,
  }) {
    if (_routeAwareManager != null) {
      _routeAwareManager.popLock.synchronized(() {
        _popUntilPathOrPush(
          context,
          path,
          transitionDelegate: transitionDelegate,
        );

        /// Late cleanup
        routeAwareManager.popLock.synchronized(() {
          routeAwareManager.popPaths.clear();
        });
      });
    } else {
      _popUntilPathOrPush(
        context,
        path,
        transitionDelegate: transitionDelegate,
      );
    }
  }

  /// Pop to root screen
  void popToRoot(BuildContext context) {
    popUntilPathOrPush(context, rootContentPath);
  }

  /// Returns true if found
  void transientPopUntilPath(BuildContext context, ContentPath path) {
    if (_routeAwareManager != null) {
      _routeAwareManager.popLock.synchronized(() {
        _popUntilPath(context, path, handleRoot: true);

        /// Late cleanup
        routeAwareManager.popLock.synchronized(() {
          routeAwareManager.popPaths.clear();
        });
      });
    } else {
      _popUntilPath(context, path);
    }
  }

  /// Pop until a matching path or push it
  void transientPop(BuildContext context, [Object? result]) {
    if (_routeAwareManager != null) {
      _routeAwareManager.popLock.synchronized(() {
        routeAwareManager.popTransient = true;
        _transientPop(context, result);

        /// Late cleanup
        routeAwareManager.popLock.synchronized(() {
          routeAwareManager.popTransient = false;
        });
      });
    } else {
      _transientPop(context, result);
    }
  }

  void _popUntilPathOrPush(
    BuildContext context,
    ContentPath path, {
    TransitionDelegate? transitionDelegate,
  }) {
    var found = _popUntilPath(
      context,
      path,
    ); // print('popUntil($path) found $found');
    if (!found) {
      pushPath<void>(path, transitionDelegate: transitionDelegate);
    }
  }

  /// Returns true if fount
  ///
  /// if handleRoot is true, the root is handled as well as excluded from onResume
  bool _popUntilPath(
    BuildContext context,
    ContentPath path, {
    bool? handleRoot,
  }) {
    var found = false;

    Navigator.of(context).popUntil((route) {
      var name = route.settings.name;
      if (name != null) {
        var matches = path.matchesString(name);
        if (_routeAwareManager != null) {
          if (!matches || (handleRoot ?? false)) {
            routeAwareManager.popPaths.add(name);
          }
        }

        found = found || matches;
        return matches;
      }
      return false;
    });
    return found;
  }

  /// Pop last no onResume
  void _transientPop(BuildContext context, Object? result) {
    Navigator.of(context).pop(result);
  }

  // Use ContentNavigator.push instead
  // @protected
  /// Push a new route, with an optional transitionDelegate
  Future<T?> push<T>(
    ContentPathRouteSettings rs, {
    TransitionDelegate? transitionDelegate,
  }) async {
    if (contentNavigatorDebug) {
      _log('Push $rs');
    }

    return _push(rs, transitionDelegate: transitionDelegate);
  }

  /// index of the page verifying the predicate, -1 if none
  int lastIndexWhere(bool Function(ContentPathRouteSettings rs) predicate) {
    var index = -1;
    for (var i = _stack.length - 1; i >= 0; i--) {
      var item = _stack[i];
      if (predicate(item.rs)) {
        index = i;
        break;
      }
    }
    return index;
  }

  /// Remove all route until index is reached from the top
  ///
  /// -1 does nothing
  ///
  /// You must push another route.
  void transientPopUntil(int index) {
    if (index != -1) {
      for (var i = _stack.length - 1; i > index; i--) {
        transientPopItem(i, null);
      }
    }
  }

  /// Remove all route until index is reached from the top
  ///
  /// You must push another route.
  void transientPopAll() {
    for (var i = _stack.length - 1; i >= 0; i--) {
      transientPopItem(i, null);
    }
  }

  void _log(String message) {
    // ignore: avoid_print
    print('/cn $message');
  }

  @override
  String toString() =>
      _stack.isEmpty ? 'ContentNavigator(empty)' : 'CN(${_stack.last.rs.path})';

  @protected
  /// Transient pop item
  void transientPopItem(int index, Object? result) {
    var item = _stack[index];
    if (!item.completer.isCompleted) {
      item.completer.complete(result);
    }
    _removeItem(index);
  }

  /// Return the same route if match found
  ContentPath? findPath(ContentPath path) {
    var pageDef = contentNavigator!.def.findPageDef(path);
    if (contentNavigatorDebug) {
      _log('findPath: found $path: $pageDef in ${contentNavigator!.def}');
    }
    // Return the wanted root
    return pageDef?.path != null ? path : null;
  }

  /// Called by the system.
  ///
  /// Don't change if current matches.
  Future<void> setNewRoutePath(ContentPath path) async {
    /*
    // Delete all page from stack up to path and recreate path
    for (var i = _stack.length - 1; i >= 0; i--) {
      // Remove until matching
      var stackPath = _stack[i];
      var item = _stack.removeAt(i);
      if (item.routePath.path == path) {
        break;
      }
    }*/
    var rs = ContentPathRouteSettings(path);
    // devPrint('setNewRoutePath($crp)');
    var absPath = path.toPathString();

    // devPrint('looking for $absPath in $_stack');
    var index = lastIndexWhere(
      (routePath) => routePath.path.toPathString() == absPath,
    );
    if (index != -1) {
      // print('found and reuse $index');
      transientPopUntil(index);
      // devPrint(_stack);
      _notifyNavigatorChanges();
      return;

      //
    }
    /*
        if (absPath == currentPath?.toPath()) {
      if (contentNavigatorDebug) {
        print('Already current');
      }
      return;
    } else {
         */

    return await _push(rs);
  }
}

/// Bloc provider extension
extension ContentNavigatorBlocExt on ContentNavigatorBloc {
  /// Push a path.
  Future<T?> pushPath<T>(
    ContentPath path, {
    Object? arguments,
    TransitionDelegate? transitionDelegate,
  }) {
    if (kDebugMode) {
      if (!path.isValid()) {
        throw ArgumentError('Invalid path', path.toString());
      }
    }
    return push<T>(
      path.routeSettings(arguments),
      transitionDelegate: transitionDelegate,
    );
  }
}

/// global object
class ContentNavigatorDef {
  /// List of content page definitions
  final List<ContentPageDef> defs;

  /// Content navigator definition
  const ContentNavigatorDef({required this.defs});

  void _check() {
    // devPrint('defs: ${defs.map((def) => def.path)}');
    // Check defs

    var defSet = <ContentPath?>{};
    for (var def in defs) {
      var path = def.path;
      for (var existing in defSet) {
        assert(
          !path.matchesPath(existing),
          'ContentNavigator page definition $def already exists ($existing)',
        );
      }
      defSet.add(path);
    }
  }

  /// Find a page definition
  ContentPageDef? findPageDef(ContentPath? path) {
    if (path != null) {
      return defs.findContentPageDef(path);
    }
    return null;
  }

  @override
  String toString() => defs.toString();
}

/// Content navigator top object.
class ContentNavigator extends StatefulWidget {
  /// The content navigator definition
  final ContentNavigatorDef def;

  /// The child widget
  final Widget? child;

  /// Optional observers
  final List<NavigatorObserver>? observers;

  /// The global navigator object
  static ContentNavigatorBloc of(BuildContext context) =>
      BlocProvider.of<ContentNavigatorBloc>(context);

  /// Content navigator
  const ContentNavigator({
    super.key,
    required this.def,
    this.child,
    this.observers,
  });

  @override
  State<ContentNavigator> createState() => _ContentNavigatorState();

  /// Push a path setting.
  static Future<T?> push<T>(
    BuildContext context,
    ContentPathRouteSettings rs, {
    TransitionDelegate? transitionDelegate,
  }) async {
    return await ContentNavigator.of(
      context,
    ).push<T>(rs, transitionDelegate: transitionDelegate);
  }

  /// Push a replacement path setting.
  static Future<T?> pushReplacement<T>(
    BuildContext context,
    ContentPathRouteSettings rs, {

    /// current pop result
    Object? result,
    TransitionDelegate? transitionDelegate,
  }) {
    var cn = ContentNavigator.of(context);
    cn.transientPop(context, result);
    return cn.push<T>(rs, transitionDelegate: transitionDelegate);
  }

  /// Push a path.
  static Future<T?> pushPath<T>(
    BuildContext context,
    ContentPath contentPath, {
    Object? arguments,
    TransitionDelegate? transitionDelegate,
  }) {
    return push(
      context,
      contentPath.routeSettings(arguments),
      transitionDelegate: transitionDelegate,
    );
  }

  /// Push a replacement path.
  static Future<T?> pushReplacementPath<T>(
    BuildContext context,
    ContentPath contentPath, {
    Object? arguments,

    /// Current pop result
    Object? result,
    TransitionDelegate? transitionDelegate,
  }) {
    return pushReplacement(
      context,
      contentPath.routeSettings(arguments),
      result: result,
      transitionDelegate: transitionDelegate,
    );
  }

  /// Do not trigger onResume()...WIP
  static void transientPop(BuildContext context, [Object? result]) {
    return ContentNavigator.of(context).transientPop(context, result);
  }

  /// Pop until a matching path or push it
  /// Do not trigger onResume()...WIP
  static void popUntilPathOrPush(BuildContext context, ContentPath path) {
    ContentNavigator.of(context).popUntilPathOrPush(context, path);
  }

  /// Pop to root screen
  static void popToRoot(BuildContext context) {
    popUntilPathOrPush(context, rootContentPath);
  }

  /// Pop until a matching path
  /// Do not trigger onResume()...WIP
  static void transientPopUntilPath(BuildContext context, ContentPath path) {
    ContentNavigator.of(context).transientPopUntilPath(context, path);
  }

  /// Push a new route using navigator
  static Future<T?> pushBuilder<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool? noAnimation,
  }) async {
    return await Navigator.of(
      context,
    ).pushBuilder<T>(builder: builder, noAnimation: noAnimation);
  }
}

/// Bloc provider extension (private)
extension ContentNavigatorBlocPrvExt on ContentNavigatorBloc {
  /// Find the index of a content path in the stack
  int? _findContentPathIndex(ContentPath contentPath) {
    for (var i = _stack.length - 1; i >= 0; i--) {
      var item = _stack[i];
      if (item.rs.path == contentPath) {
        return i;
      }
    }
    return null;
  }

  /// Transient pop item
  void _setPopResult(int index, Object? result) {
    var item = _stack[index];
    if (!item.completer.isCompleted) {
      item.completer.complete(result);
    }
  }

  /// On pop page
  bool onPopPageRoute(Route route, Object? result) {
    var name = route.settings.name;
    return _onPopPageName(name, result);
  }

  /// On pop page
  bool _onPopPageName(String? name, [Object? result]) {
    if (name == null) {
      return false;
    }
    // pop if found
    var contentPath = ContentPath.fromString(name);
    return _onPopContentPath(contentPath, result);
  }

  bool _onPopContentPath(ContentPath contentPath, Object? result) {
    // Find in stack, if found remove
    var i = _findContentPathIndex(contentPath);
    if (i != null) {
      transientPopItem(i, result);
      return true;
    }
    return false;
  }

  /// On pop page
  bool onDidRemovePage(Page page) {
    var name = page.name;
    return _onPopPageName(name);
  }

  /// Pop a context path.
  void onPopInvoked(ContentPath contentPath, Object? result) {
    var i = _findContentPathIndex(contentPath);
    if (i != null) {
      _setPopResult(i, result);
    }
  }
}

class _ContentNavigatorState extends State<ContentNavigator> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocBuilder: () => ContentNavigatorBloc(contentNavigator: widget),
      child: widget.child!,
    );
  }
}
