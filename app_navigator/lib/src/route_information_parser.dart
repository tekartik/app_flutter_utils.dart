import 'import.dart';

class ContentRouteInformationParser
    extends RouteInformationParser<ContentPath> {
  final ContentNavigatorBloc cnBloc;

  ContentRouteInformationParser(this.cnBloc);

  @override
  Future<ContentPath> parseRouteInformation(
      RouteInformation routeInformation) async {
    return parseRouteInformationSync(routeInformation);
  }

  void _log(String message) {
    // ignore: avoid_print
    print('/cnip $message');
  }

  ContentPath parseAnyRouteInformationSync(RouteInformation routeInformation) {
    final uri = routeInformation.uri;

    var path = ContentPath.fromString(uri.path);
    if (contentNavigatorDebug) {
      _log('parsing $uri: $path');
    }
    return path;
  }

  ///Parse a route information to generate a known content path
  ContentPath parseRouteInformationSync(RouteInformation routeInformation) {
    var path = parseAnyRouteInformationSync(routeInformation);
    //var pageDef = contentNavigatorDef.findPageDef(path);
    var contentPath = cnBloc.findPath(path);
    if (contentPath != null) {
      // return pageDef.path
      if (contentNavigatorDebug) {
        _log('parsed $contentPath');
      }
      return contentPath;
    }

    if (contentNavigatorDebug) {
      _log('/cnip:  !!!parseRouteInformation nothing found!');
    }
    throw StateError('invalid path: ${routeInformation.uri}');
  }

  @override
  RouteInformation restoreRouteInformation(ContentPath? configuration) {
    // devPrint('restore: ${path}');
    // Convert the current path to a displayable string
    if (configuration is ContentPath) {
      var location = configuration.toPath();
      return RouteInformation(uri: Uri.parse(location));
    }
    return RouteInformation(uri: Uri.parse('/?'));
  }
}
