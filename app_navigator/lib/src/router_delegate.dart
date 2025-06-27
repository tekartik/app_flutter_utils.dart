import 'import.dart';

/// Router delegate for content navigator
class ContentRouterDelegate extends RouterDelegate<ContentPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<ContentPath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  /// Content navigator bloc
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
    // ignore: avoid_print
    print('/cnr $message');
  }

  @override
  Widget build(BuildContext context) {
    var cnPages = cnBloc.currentPages;
    if (contentNavigatorDebug) {
      _log('build navigator $cnPages');
    }

    var observers = cnBloc.contentNavigator?.observers;

    var pages = cnBloc.currentPages;

    return Navigator(
      key: navigatorKey,

      /// Use the current transitionDelegate if any...
      transitionDelegate:
          // ignore: invalid_use_of_protected_member
          cnBloc.currentTransitionDelegate ?? cnBloc.transitionDelegate,
      pages: pages.toList(),
      // Handle imperative way

      // ignore: deprecated_member_use
      onPopPage: contentNavigatorUseOnPopPage
          ? (route, result) {
              if (contentNavigatorDebug) {
                _log('popping ${route.settings.name} result $result');
              }
              // test 2023-09-18
              // if (false) {
              try {
                if (!route.didPop(result)) {
                  return false;
                }
              } catch (e, st) {
                _log('onPopPage error $e $st');
                // rethrow;
              }

              // if (contentNavigatorDebug) {
              //  _log('popping2 ${route.settings.name} result $result');
              // }
              // ignore: invalid_use_of_protected_member
              cnBloc.onPopPageRoute(route, result);
              notifyListeners();

              return true;
            }
          : null,
      onDidRemovePage: contentNavigatorUseOnPopPage
          ? null
          : (page) {
              if (contentNavigatorDebug) {
                _log('onDidRemovePage $page');
              }
              // ignore: invalid_use_of_protected_member
              cnBloc.onDidRemovePage(page);
              scheduleMicrotask(() => notifyListeners());
            },
      observers: observers ?? <NavigatorObserver>[],
    );
  }

  @override
  Future<void> setNewRoutePath(ContentPath configuration) async {
    if (contentNavigatorDebug) {
      _log('delegate.setNewRoutePath($configuration) called');
    }
    await cnBloc.setNewRoutePath(configuration);
  }
}
