import 'import.dart';

/// Route information parser for content navigator
class ContentRouteInformationParser
    extends RouteInformationParser<ContentPath> {
  /// Content navigator bloc
  final ContentNavigatorBloc cnBloc;

  /// Constructor
  ContentRouteInformationParser(this.cnBloc);

  @override
  Future<ContentPath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return parseRouteInformationSync(routeInformation);
  }

  void _log(String message) {
    // ignore: avoid_print
    print('/cnip $message');
  }

  @override
  RouteInformation restoreRouteInformation(ContentPath? configuration) {
    // devPrint('restore: ${path}');
    // Convert the current path to a displayable string
    if (configuration is ContentPath) {
      var location = configuration.toPathString();

      return RouteInformation(uri: Uri.parse(location));
    }

    return RouteInformation(uri: Uri.parse('/?'));
  }
}

/// Private extension
extension ContentRouteInformationParserPrvExt on ContentRouteInformationParser {
  /// Parse a route information to generate a known content path
  ContentPath parseAnyRouteInformationSync(RouteInformation routeInformation) {
    final uri = routeInformation.uri;

    var path = ContentPath.fromString(uri.path);
    if (contentNavigatorDebug) {
      _log('parsing $uri: $path');
    }
    return path;
  }

  /// Parse a route information to generate a known content path.
  ///
  /// If the path does not match any page definition (unknown deep link, url
  /// typed by hand on the web), fall back to the home path instead of failing.
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

    var homePath = cnBloc.homePath;
    if (contentNavigatorDebug) {
      _log('nothing found for ${routeInformation.uri}, using home $homePath');
    }
    return homePath;
  }
}
