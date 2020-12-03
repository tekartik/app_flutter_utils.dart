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
  final ContentRoutePath routePath;
  final ContentPageDef def;
  final completer = Completer.sync();

  _ContentPageInStack({@required this.def, @required this.routePath});

  void dispose() {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  /// Build for navigator
  Page build() {
    // ignore: deprecated_member_use_from_same_package
    var page = def.builder(routePath);
    // Name and arguments must match
    assert(page.name == routePath.path.toPath(),
        'name of page must match the content path');
    assert(
        page.arguments == routePath.arguments, 'arguments of page must match');
    // devPrint('build page ${page.key} for $routePath');
    return page;
  }

  @override
  String toString() => routePath?.toString() ?? def.toString() ?? '?';
}

class _ContentRoutePathInStack {
  static int _id = 0;
  final int id;
  final ContentRoutePath routePath;

  _ContentRoutePathInStack(this.routePath) : id = ++_id;

  @override
  String toString() => '<$id> $routePath';
}

class ContentNavigatorBloc extends BaseBloc {
  final ContentNavigator contentNavigator;
  ContentRouteInformationParser _routeInformationParser;
  ContentRouterDelegate _routerDelegate;

  ContentNavigatorBloc({this.contentNavigator});

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
      var pageDef = contentNavigator.def.defs.first;
      var item = _ContentPageInStack(
          def: pageDef, routePath: ContentRoutePath(pageDef.path));
      _stack.add(item);
    }
    return _stack.map((e) => e.build());
  }

  /// Temp
  @visibleForTesting
  ChangeNotifier changeNotifier;

  _ContentPageInStack get _currentPageInStack =>
      _stack.isEmpty ? null : _stack.last;

  ContentRoutePath get currentRoutePath => contentNavigatorUseDeclarative
      ? _currentPageInStack?.routePath
      : _currentContentRoutePathInStack?.routePath;

  _ContentRoutePathInStack get _currentContentRoutePathInStack =>
      _crpStack.isEmpty ? null : _crpStack.last;

  // If last matches
  bool _crpCurrentPathEquals(ContentPath path) {
    return (_currentContentRoutePathInStack?.routePath?.path == path);
  }

  /// Current path.
  ContentPath get currentPath => currentRoutePath?.path;

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
    var path = settings.name;
    var arguments = settings.arguments;
    var contentPath = ContentPath.fromString(path);
    if (contentNavigatorDebug) {
      _log('onGenerateRoute($settings) => $contentPath');
    }
    var pageDef = contentNavigator.def.findPageDef(contentPath);

    var crp = ContentRoutePath(contentPath, arguments);
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
          _crpAdd(crp);
        }
      }
    }

    return MaterialPageRoute(builder: (context) => pageDef.screenBuilder(crp));
  }

  // TODO @alex remove call to notify listener
  Future<T> _push<T>(ContentRoutePath routePath) async {
    // devPrint('Changed $routePath');

    var pageDef = contentNavigator.def.findPageDef(routePath.path);
    if (contentNavigatorDebug) {
      _log('found: $pageDef');
    }
    // Find in stack, if found remove
    _stack.removeWhere((item) {
      return item.routePath.path == routePath.path;
    });
    var item = _ContentPageInStack(def: pageDef, routePath: routePath);
    _stack.add(item);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    changeNotifier.notifyListeners();
    // TODO handled future completion

    // TODO wait for pop...
    return await item.completer.future as T;
  }

  // User ContentNavigator.push instead
  @protected
  Future<T> push<T>(BuildContext context, ContentRoutePath routePath) async {
    if (contentNavigatorDebug) {
      _log('Push $routePath');
    }
    if (contentNavigatorUseDeclarative) {
      return await _push(routePath);
    } else {
      // Compat imperative way
      var crpItem = _crpAdd(routePath);
      try {
        return await Navigator.of(context)
            .pushNamed(routePath.path.toPath(), arguments: routePath.arguments);
      } finally {
        _crpRemoveItem(crpItem);
      }
    }
  }

  _ContentRoutePathInStack _crpAdd(ContentRoutePath crp) {
    var crpItem = _ContentRoutePathInStack(crp);
    _crpStack.add(crpItem);
    return crpItem;
  }

  void _crpRemoveItem(_ContentRoutePathInStack item) {
    _crpStack.removeWhere((element) => element.id == item.id);
    // devPrint(_crpStack);
  }

  void _log(String message) {
    print('/cn $message');
  }

  @override
  String toString() => _stack.isEmpty
      ? 'ContentNavigator(empty)'
      : 'CN(${_stack.last.routePath.path})';

  bool onPopPage(Route route, result) {
    if (_stack.isNotEmpty) {
      // Complete with result
      var item = _stack.last;
      if (!item.completer.isCompleted) {
        item.completer.complete(result);
      }
      _removeItem(_stack.length - 1);
    }
    // no need to call notify listeners here, done in router

    // devPrint('pop');
    return true;
  }

  /// Return the same route if match found
  ContentPath findPath(ContentPath path) {
    var pageDef = contentNavigator.def.findPageDef(path);
    if (contentNavigatorDebug) {
      _log('findPath: found $path: $pageDef in ${contentNavigator.def}');
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
    var crp = ContentRoutePath(path);
    // devPrint('setNewRoutePath($crp)');
    var absPath = path.toPath();
    if (absPath == currentPath?.toPath()) {
      if (contentNavigatorDebug) {
        print('Already current');
      }
    } else {
      // Find in stack and removed then, not the last one we checked already
      for (var i = 0; i < _stack.length - 1; i++) {
        var _stackPath = _stack[i].routePath.path;
        if (absPath == _stackPath?.toPath()) {
          print('found');
        }
      }
    }
    if (contentNavigatorUseDeclarative) {
      return await _push(crp);
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

  ContentNavigatorDef({@required this.defs});
  ContentPageDef findPageDef(ContentPath path) {
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
  final Widget child;

  /// The global navigator object
  static ContentNavigatorBloc of(BuildContext context) =>
      BlocProvider.of<ContentNavigatorBloc>(context);

  const ContentNavigator({Key key, @required this.def, this.child})
      : super(key: key);

  @override
  _ContentNavigatorState createState() => _ContentNavigatorState();

  static Future<T> push<T>(
      BuildContext context, ContentRoutePath contentRoutePath) async {
    return await ContentNavigator.of(context)
        .push<T>(context, contentRoutePath);
  }
}

class _ContentNavigatorState extends State<ContentNavigator> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        blocBuilder: () => ContentNavigatorBloc(contentNavigator: widget),
        child: widget.child);
  }
}
