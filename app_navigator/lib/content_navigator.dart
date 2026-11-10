/// A Navigator 2.0 router on typed content paths (`/note/1`): declare
/// [ContentPath]s (a [ContentPathBase] with its [ContentPathField]s), bind
/// them to screens with [ContentPageDef]s in a [ContentNavigatorDef], wrap
/// the app in a [ContentNavigator] and give `ContentNavigator.of(context)`'s
/// `routerConfig` to `MaterialApp.router`.
library;

export 'src/content_navigator.dart'
    show
        ContentNavigator,
        ContentNavigatorBloc,
        ContentNavigatorBlocExt,
        ContentNavigatorDef,
        contentNavigatorDebug,
        contentNavigatorUseOnPopPage;
export 'src/content_page.dart'
    show ContentPageDef, ContentPageDefListExt, ContentScreenBuilder;
export 'src/content_path.dart'
    show
        ContentPath,
        ContentPathExt,
        ContentPathBase,
        rootContentPath,
        rootContentPathString;
export 'src/content_path_field.dart' show ContentPathField;
export 'src/content_path_part.dart' show ContentPathPart;
export 'src/content_path_route_settings.dart'
    show
        ContentPathRouteSettings,
        ContentPathRouteSettingsExt,
        ContentPathRouteExt;
export 'src/navigator_ext.dart' show TekartikNavigatorStateExt;
export 'src/route_information_parser.dart' show ContentRouteInformationParser;
export 'src/router_delegate.dart' show ContentRouterDelegate;
export 'src/transition_delegate.dart' show NoAnimationTransitionDelegate;
