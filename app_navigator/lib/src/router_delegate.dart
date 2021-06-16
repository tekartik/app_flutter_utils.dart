import 'import.dart';

class ContentRouterDelegate extends RouterDelegate<ContentPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<ContentPath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final ContentNavigatorBloc cnBloc;

  /// Optional observers
  ContentRouterDelegate(this.cnBloc)
      : navigatorKey = GlobalKey<NavigatorState>() {
    // Temp set in bloc until bloc holds the router.
    // ignore: invalid_use_of_visible_for_testing_member
    cnBloc.changeNotifier = this;
    /*
    pathNotifier.addListener(() {
      cnBloc.push(pathNotifier.value);

      notifyListeners();
    });

     */
  }

  @override
  ContentPath? get currentConfiguration {
    var path = cnBloc.currentPath;
    return path;
  }

  // ContentPath get _currentPath => pathNotifier.value;

  //final _stack = <ContentPageDef>[];

  void _log(String message) {
    print('/cnr $message');
  }

  @override
  Widget build(BuildContext context) {
    var cnPages = cnBloc.currentPages;
    if (contentNavigatorDebug) {
      _log('build navigator $cnPages');
    }

    var observers = cnBloc.contentNavigator?.observers;

    return Navigator(
      key: navigatorKey,
      transitionDelegate: cnBloc.transitionDelegate,

      pages: [
        /*
        if (false)
          MaterialPage(
              key: ValueKey('Start Page'),
              child: Builder(
                builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text('Start Page'),
                    ),
                    body: Placeholder()),
              )),
        */
        //if (_selectedBook != null) BookDetailsPage(book: _selectedBook),
        //..._stack.map((e) => e.builder()),
        ...cnBloc.currentPages
      ],
      // Handle imperative way
      onGenerateRoute:
          contentNavigatorUseDeclarative // devWarning(false) // (contentNavigatorUseDeclarative)
              ? null
              : (settings) => cnBloc.onGenerateRoute(settings),
      onPopPage: (route, result) {
        if (contentNavigatorDebug) {
          _log('popping ${route.settings.name} result $result');
        }
        if (!route.didPop(result)) {
          return false;
        }

        // ignore: invalid_use_of_protected_member
        cnBloc.onPopPage(route, result);
        // Update the list of pages by setting _selectedBook to null

        notifyListeners();

        return true;
      },
      observers: observers != null ? observers : <NavigatorObserver>[],
    );
  }

  @override
  Future<void> setNewRoutePath(ContentPath path) async {
    if (contentNavigatorDebug) {
      _log('delegate.setNewRoutePath($path) called');
    }
    await cnBloc.setNewRoutePath(path);
  }
}
