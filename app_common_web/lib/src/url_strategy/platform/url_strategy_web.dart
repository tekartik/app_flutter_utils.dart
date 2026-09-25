import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../url_strategy_common.dart';

/// Sets the URL strategy of your web app to [strategy], unless the page url
/// enforces another one (`?url-strategy=hash` or `?url-strategy=path`).
///
/// Must be called once, before `runApp`.
///
/// You can safely call this on all platforms, i.e. also when running on mobile
/// or desktop. In that case, it will simply be a noop.
void webUseUrlStrategy(WebUrlStrategy strategy) {
  switch (webResolveUrlStrategy(strategy)) {
    case WebUrlStrategy.path:
      usePathUrlStrategy();
    case WebUrlStrategy.hash:
      setUrlStrategy(const HashUrlStrategy());
  }
}

/// Sets the URL strategy of your web app to using paths instead of a leading
/// hash (`#`), unless the page url enforces `?url-strategy=hash`.
///
/// You can safely call this on all platforms, i.e. also when running on mobile
/// or desktop. In that case, it will simply be a noop.
///
/// See also:
///  * [webUseHashUrlStrategy], which will use a hash URL strategy instead.
void webUsePathUrlStrategy() {
  webUseUrlStrategy(WebUrlStrategy.path);
}

/// Sets the URL strategy of your web app to using a leading has (`#`) instead
/// of paths, unless the page url enforces `?url-strategy=path`.
///
/// You can safely call this on all platforms, i.e. also when running on mobile
/// or desktop. In that case, it will simply be a noop.
///
/// See also:
///  * [webUsePathUrlStrategy], which will use a path URL strategy instead.
void webUseHashUrlStrategy() {
  webUseUrlStrategy(WebUrlStrategy.hash);
}

/// True if the web app uses paths (`/settings`), false off the web.
bool get webIsPathUrlStrategy => urlStrategy is PathUrlStrategy;

/// True if the web app uses a leading hash (`/#/settings`, flutter's default),
/// false off the web.
bool get webIsHashUrlStrategy {
  var strategy = urlStrategy;
  // PathUrlStrategy extends HashUrlStrategy.
  return strategy is HashUrlStrategy && strategy is! PathUrlStrategy;
}
