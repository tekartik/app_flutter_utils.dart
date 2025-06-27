// @sealed
// abstract class ContentPage extends Page {}

import 'import.dart';

/// A content page definition (protected)
typedef ContentPageBuilder = Page Function(ContentPathRouteSettings crp);

/// A content screen builder
typedef ContentScreenBuilder = Widget Function(ContentPathRouteSettings rs);
void _log(String message) {
  // ignore: avoid_print
  print('/cnpd $message');
}

/// A content page definition
abstract class ContentPageDef {
  /// Create a content page definition
  factory ContentPageDef({
    required ContentPath path,
    required ContentScreenBuilder screenBuilder,
  }) {
    return _ContentPageDef(path: path, screenBuilder: screenBuilder);
  }

  /// The path definition
  late ContentPath path;

  /// The builder generagted
  ContentPageBuilder get builder;

  @override
  String toString() => 'def: $path';

  /// The screen builder
  ContentScreenBuilder? get screenBuilder;
}

class _ContentPageDef implements ContentPageDef {
  @override
  late Page Function(ContentPathRouteSettings crp) builder;

  @override
  ContentPath path;

  @override
  final Widget Function(ContentPathRouteSettings crp)? screenBuilder;

  _ContentPageDef({required this.path, this.screenBuilder}) {
    // var name = path?.toPath();
    // devPrint('Building material page from $name');

    late ContentNavigatorBloc cnBloc;
    builder = (routePath) {
      var pageContentPath = routePath.path;
      var name = pageContentPath.toPathString();
      return MaterialPage(
        name: name,
        arguments: routePath.arguments,
        key: ValueKey(name),
        child: Builder(
          builder: (context) {
            cnBloc = ContentNavigator.of(context);
            return screenBuilder!(routePath);
          },
        ),
        onPopInvoked: contentNavigatorUseOnPopPage
            ? (didPop, result) {}
            : (didPop, result) {
                if (contentNavigatorDebug) {
                  _log('onPopInvoked($routePath, didPop: $didPop, $result');
                }
                if (didPop) {
                  cnBloc.onPopInvoked(pageContentPath, result);
                }
              },
      );
    };
  }

  @override
  String toString() => 'def:$path';
}

/// List extension
extension ContentPageDefListExt on List<ContentPageDef> {
  /// Find a page definition
  ContentPageDef? findContentPageDef(ContentPath contentPath) {
    return firstWhereOrNull((element) => element.path.matchesPath(contentPath));
  }

  /// Override an existing route
  void override(ContentPageDef contentPageDef) {
    var path = contentPageDef.path;
    var existing = findContentPageDef(path);
    if (existing != null) {
      remove(existing);
    }
    if (path == rootContentPath) {
      insert(0, contentPageDef);
    } else {
      add(contentPageDef);
    }
  }

  /// Override all matching existing routes
  void overrideAll(List<ContentPageDef> contentPageDefs) {
    for (var contentPageDef in contentPageDefs) {
      override(contentPageDef);
    }
  }
}
