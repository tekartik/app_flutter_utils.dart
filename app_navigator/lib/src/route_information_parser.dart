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
    print('/cnip $message');
  }

  ContentPath parseAnyRouteInformationSync(RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location);

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
    return null;
  }

  @override
  RouteInformation restoreRouteInformation(ContentPath path) {
    // devPrint('restore: ${path}');
    // Convert the current path to a displayable string
    if (path is ContentPath) {
      var location = path.toPath();
      return RouteInformation(location: location);
    }
    return const RouteInformation(location: '/?');
  }
}
