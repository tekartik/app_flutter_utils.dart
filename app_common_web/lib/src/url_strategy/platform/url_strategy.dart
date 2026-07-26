import 'package:tekartik_app_flutter_common_web_utils/url_strategy.dart';

export 'url_strategy_stub.dart'
    if (dart.library.js_interop) 'url_strategy_web.dart';

/// compat
void setHashUrlStrategy() => webUseHashUrlStrategy();

/// compat
void setPathUrlStrategy() => webUsePathUrlStrategy();
