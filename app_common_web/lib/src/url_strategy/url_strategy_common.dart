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

/// Meta name of the page enforcing the url strategy, after the query:
/// `<meta name="url-strategy" content="hash">`, what a server rewriting the
/// entry injects (tkwhost does, its sites are hash sites by default), so
/// that the plain page url works too.
const webUrlStrategyMetaName = 'url-strategy';

/// The url strategy named [value] (`hash` or `path`, any case), null if none
/// or unknown.
WebUrlStrategy? webUrlStrategyFromName(String? value) {
  if (value == null) {
    return null;
  }
  return WebUrlStrategy.values.asNameMap()[value.trim().toLowerCase()];
}

/// The url strategy enforced by the query of [uri], null if none or unknown.
WebUrlStrategy? webUrlStrategyFromUri(Uri uri) =>
    webUrlStrategyFromName(uri.queryParameters[webUrlStrategyQueryParameter]);

/// The url strategy to use: the one enforced by the query of [uri] (default
/// to [Uri.base], the page url on the web) if any, then the one enforced by
/// the page meta [metaContent] (the `content` of
/// `<meta name="url-strategy">`), [strategy] otherwise.
WebUrlStrategy webResolveUrlStrategy(
  WebUrlStrategy strategy, {
  Uri? uri,
  String? metaContent,
}) {
  return webUrlStrategyFromUri(uri ?? Uri.base) ??
      webUrlStrategyFromName(metaContent) ??
      strategy;
}
