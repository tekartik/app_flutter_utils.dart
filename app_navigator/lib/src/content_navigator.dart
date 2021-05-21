import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

import 'import.dart';

/// Should be true
// false to use the old way
/// The new Navigator 2.0 way
bool contentNavigatorUseDeclarative =
    true; // devWarning(false); // true; // devWarning(false);

// To set to true for internal debugging and heavy logs
var contentNavigatorDebug = false; // devWarning(true);

class _ContentPageInStack {
  final ContentPathRouteSettings rs;
  final ContentPageDef? def;
  final completer = Completer.sync();

  _ContentPageInStack({required this.def, required this.rs});

  void dispose() {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  /// Build for navigator
  Page build() {
    // ignore: deprecated_member_use_from_same_package, deprecated_member_use
    var page = def!.builder!(rs);
    // Name and arguments must match
    assert(page.name == rs.path.toPath(),
        'name of page must match the content path');
    assert(page.arguments == rs.arguments, 'arguments of page must match');
    // devPrint('build page ${page.key} for $routePath');
    return page;
  }

  @override
  String toString() => rs.toString();
}

class _ContentRoutePathInStack {
  static int _id = 0;
  final int id;
  final ContentPathRouteSettings rs;

  _ContentRoutePathInStack(this.rs) : id = ++_id;

  @override
  String toString() => '<$id> $rs';
}

class ContentNavigatorBloc extends BaseBloc {
  final ContentNavigator? contentNavigator;
  ContentRouteInformationParser? _routeInformationParser;
  ContentRouterDelegate? _routerDelegate;
  TransitionDelegate transitionDelegate;

  ContentNavigatorBloc(
      {this.contentNavigator,
      this.transitionDelegate = const DefaultTransitionDelegate()});

  ContentRouterDelegate get routerDelegate =>
      _routerDelegate ??= ContentRouterDelegate(this);

  ContentRouteInformationParser get routeInformationParser =>
      _routeInformationParser ??= ContentRouteInformationParser(this);

  final _stack = <_ContentPageInStack>[];

  final _crpStack = <_ContentRoutePathInStack>[];

  // Current pages
  Iterable<Page> get currentPages {
    if (_stack.isEmpty) {
      // Create a root if needed
      var pageDef = contentNavigator!.def.defs.first;
      var item = _ContentPageInStack(
          def: pageDef, rs: ContentPathRouteSettings(pageDef.path));
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

  ContentPathRouteSettings? get currentRoutePath =>
      contentNavigatorUseDeclarative
          ? _currentPageInStack?.rs
          : _currentContentRoutePathInStack?.rs;

  _ContentRoutePathInStack? get _currentContentRoutePathInStack =>
      _crpStack.isEmpty ? null : _crpStack.last;

  // If last matches
  bool _crpCurrentPathEquals(ContentPath path) {
    return (_currentContentRoutePathInStack?.rs.path == path);
  }

  /// Current path.
  ContentPath? get currentPath => currentRoutePath?.path;

  void _removeItem(int index) {
    var item = _stack[index];
    item.dispose();
    _stack.removeAt(index);
  }

  /// Old mechanism simulation
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // devPrint('using old onGenerateRoute for $settings');
    //var info = routeInformationParser.parseRouteInformationSync(
    //    RouteInformation(location: settings.name, state: settings.arguments));
    var path = settings.name!;
    var arguments = settings.arguments;
    var contentPath = ContentPath.fromString(path);
    if (contentNavigatorDebug) {
      _log('onGenerateRoute($settings) => $contentPath');
    }
    var pageDef = contentNavigator!.def.findPageDef(contentPath);

    var rs = ContentPathRouteSettings(contentPath, arguments);
    if (!contentNavigatorUseDeclarative) {
      // var current = _currentContentRoutePathInStack;
      // devPrint('current: $current');
      // Find last added if it matches
      if (_crpCurrentPathEquals(contentPath)) {
        // devPrint('matching: $current');
      } else {
        // devPrint('onGenerateRoute: $crp not matching current: $current, push?');
        if (!contentNavigatorUseDeclarative) {
          // Compat imperative way, a route was pushed by name?
          _crpAdd(rs);
        }
      }
    }

    return MaterialPageRoute(builder: (context) => pageDef!.screenBuilder!(rs));
  }

  void _notifyNavigatorChanges() {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    changeNotifier.notifyListeners();
  }

  // TODO @alex remove call to notify listener
  Future<T> _push<T>(ContentPathRouteSettings rs) async {
    // devPrint('Changed $routePath');

    var pageDef = contentNavigator!.def.findPageDef(rs.path);
    if (contentNavigatorDebug) {
      _log('found: $pageDef');
    }
    if (pageDef == null) {
      print('No page found for route settings ${rs.path}');
    }

    // Find in stack, if found remove
    for (var i = _stack.length - 1; i >= 0; i--) {
      var item = _stack[i];
      if (item.rs.path == rs.path) {
        transientPopItem(i, null);
      }
    }
    var item = _ContentPageInStack(def: pageDef, rs: rs);
    _stack.add(item);
    _notifyNavigatorChanges();
    // TODO handled future completion

    // TODO wait for pop...
    return await item.completer.future as T;
  }

  // User ContentNavigator.push instead
  // @protected
  Future<T?> push<T>(ContentPathRouteSettings rs) async {
    if (contentNavigatorDebug) {
      _log('Push $rs');
    }
    if (contentNavigatorUseDeclarative) {
      return _push(rs);
    } else {
      /*
      // Compat imperative way
      var crpItem = _crpAdd(routePath);
      try {
        return await Navigator.of(context)
            .pushNamed(routePath.path.toPath(), arguments: routePath.arguments);
      } finally {
        _crpRemoveItem(crpItem);
      }

       */
      return null;
    }
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

  @deprecated
  void popUntil(int index) => transientPopUntil(index);

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

  @deprecated
  void popAll() => transientPopAll();

  /// Remove all route until index is reached from the top
  ///
  /// You must push another route.
  void transientPopAll() {
    for (var i = _stack.length - 1; i >= 0; i--) {
      transientPopItem(i, null);
    }
  }

  _ContentRoutePathInStack _crpAdd(ContentPathRouteSettings rs) {
    var crpItem = _ContentRoutePathInStack(rs);
    _crpStack.add(crpItem);
    return crpItem;
  }

  /*
  void _crpRemoveItem(_ContentRoutePathInStack item) {
    _crpStack.removeWhere((element) => element.id == item.id);
    // devPrint(_crpStack);
  }*/

  void _log(String message) {
    print('/cn $message');
  }

  @override
  String toString() =>
      _stack.isEmpty ? 'ContentNavigator(empty)' : 'CN(${_stack.last.rs.path})';

  @protected
  bool onPopPage(Route route, Object? result) {
    // pop if found
    var contentPath = ContentPath.fromString(route.settings.name!);
    // Find in stack, if found remove
    for (var i = _stack.length - 1; i >= 0; i--) {
      var item = _stack[i];
      if (item.rs.path == contentPath) {
        transientPopItem(i, null);
        return true;
      }
    }
    return false;
  }

  @protected
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
    var absPath = path.toPath();

    // devPrint('looking for $absPath in $_stack');
    var index =
        lastIndexWhere((routePath) => routePath.path.toPath() == absPath);
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

    if (contentNavigatorUseDeclarative) {
      return await _push(rs);
    } else {
      // var current = _currentContentRoutePathInStack;
      // devPrint('current: $current');
      // Find last added if it matches
      if (_crpCurrentPathEquals(path)) {
        // devPrint('matching: $current');
      } else {
        // devPrint('${current?.routePath?.path} not matching current: $current, push?');
      }
    }
  }
}

/// global object
class ContentNavigatorDef {
  final List<ContentPageDef> defs;

  ContentNavigatorDef({required this.defs}) {
    // devPrint('defs: ${defs.map((def) => def.path)}');
    // Check defs
    if (isDebug) {
      var defSet = <ContentPath?>{};
      for (var def in defs) {
        var path = def.path;
        for (var existing in defSet) {
          assert(!path.matchesPath(existing),
              '$def already exists in ${defs.map((def) => def.path)}');
        }
        defSet.add(path);
      }
    }
  }

  ContentPageDef? findPageDef(ContentPath? path) {
    if (path != null) {
      // TODO optimize in a map by parts
      for (var def in defs) {
        if (def.path.matchesPath(path)) {
          return def;
        }
      }
    }
    return null;
  }

  @override
  String toString() => defs.toString();
}

class ContentNavigator extends StatefulWidget {
  final ContentNavigatorDef def;
  final Widget? child;

  /// The global navigator object
  static ContentNavigatorBloc of(BuildContext context) =>
      BlocProvider.of<ContentNavigatorBloc>(context);

  const ContentNavigator({Key? key, required this.def, this.child})
      : super(key: key);

  @override
  _ContentNavigatorState createState() => _ContentNavigatorState();

  static Future<T?> push<T>(
      BuildContext context, ContentPathRouteSettings rs) async {
    return await ContentNavigator.of(context).push<T>(rs);
  }
}

class _ContentNavigatorState extends State<ContentNavigator> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        blocBuilder: () => ContentNavigatorBloc(contentNavigator: widget),
        child: widget.child!);
  }
}
