/// The url strategy of a flutter web app.
enum WebUrlStrategy {
  /// Paths, `/settings`, the server must serve `index.html` for every path.
  path,

  /// A leading hash, `/#/settings`, flutter's default, works on any server.
  hash,
}

/// Query parameter of the page url enforcing the url strategy, whatever the
/// app asks for: `?url-strategy=hash` or `?url-strategy=path`.
///
/// It must be in the query of the page url, before the `#`.
const webUrlStrategyQueryParameter = 'url-strategy';

/// The url strategy enforced by the query of [uri], null if none or unknown.
WebUrlStrategy? webUrlStrategyFromUri(Uri uri) {
  var value = uri.queryParameters[webUrlStrategyQueryParameter];
  if (value == null) {
    return null;
  }
  return WebUrlStrategy.values.asNameMap()[value.trim().toLowerCase()];
}

/// The url strategy to use: the one enforced in [uri] (default to [Uri.base],
/// the page url on the web) if any, [strategy] otherwise.
WebUrlStrategy webResolveUrlStrategy(WebUrlStrategy strategy, {Uri? uri}) {
  return webUrlStrategyFromUri(uri ?? Uri.base) ?? strategy;
}
