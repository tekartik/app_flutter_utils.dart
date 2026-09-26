import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_common_web_utils/url_strategy.dart';

Future<void> main() async {
  group('url_strategy', () {
    test('setPathUrlStrategy', () async {
      setPathUrlStrategy();
    });

    test('setHashUrlStrategy', () async {
      setHashUrlStrategy();
    });

    test('io', () {
      // Noop off the web.
      webUseUrlStrategy(WebUrlStrategy.path);
      expect(webIsPathUrlStrategy, isFalse);
      expect(webIsHashUrlStrategy, isFalse);
    }, testOn: '!browser');

    test('webUrlStrategyFromUri', () {
      WebUrlStrategy? fromUrl(String url) =>
          webUrlStrategyFromUri(Uri.parse(url));
      expect(fromUrl('https://example.com/'), isNull);
      expect(fromUrl('https://example.com/?url-strategy='), isNull);
      expect(fromUrl('https://example.com/?url-strategy=dummy'), isNull);
      expect(
        fromUrl('https://example.com/?url-strategy=hash'),
        WebUrlStrategy.hash,
      );
      expect(
        fromUrl('https://example.com/settings?url-strategy=path'),
        WebUrlStrategy.path,
      );
      expect(
        fromUrl('https://example.com/?a=1&url-strategy=HASH#/settings?b=2'),
        WebUrlStrategy.hash,
      );
      // Only the query of the page url counts, not the one of the hash route.
      expect(
        fromUrl('https://example.com/#/settings?url-strategy=hash'),
        isNull,
      );
    });

    test('webResolveUrlStrategy', () {
      WebUrlStrategy resolve(WebUrlStrategy strategy, String url) =>
          webResolveUrlStrategy(strategy, uri: Uri.parse(url));
      expect(
        resolve(WebUrlStrategy.path, 'https://example.com/'),
        WebUrlStrategy.path,
      );
      expect(
        resolve(WebUrlStrategy.hash, 'https://example.com/'),
        WebUrlStrategy.hash,
      );
      expect(
        resolve(WebUrlStrategy.path, 'https://example.com/?url-strategy=hash'),
        WebUrlStrategy.hash,
      );
      expect(
        resolve(WebUrlStrategy.hash, 'https://example.com/?url-strategy=path'),
        WebUrlStrategy.path,
      );
    });

    test('webResolveUrlStrategy meta', () {
      WebUrlStrategy resolve(
        WebUrlStrategy strategy,
        String url,
        String? metaContent,
      ) => webResolveUrlStrategy(
        strategy,
        uri: Uri.parse(url),
        metaContent: metaContent,
      );
      // The meta when the query says nothing.
      expect(
        resolve(WebUrlStrategy.path, 'https://example.com/', 'hash'),
        WebUrlStrategy.hash,
      );
      expect(
        resolve(WebUrlStrategy.hash, 'https://example.com/', ' Path '),
        WebUrlStrategy.path,
      );
      expect(
        resolve(WebUrlStrategy.path, 'https://example.com/', 'dummy'),
        WebUrlStrategy.path,
      );
      // The query wins.
      expect(
        resolve(
          WebUrlStrategy.hash,
          'https://example.com/?url-strategy=path',
          'hash',
        ),
        WebUrlStrategy.path,
      );
      expect(webUrlStrategyFromName(null), isNull);
      expect(webUrlStrategyMetaName, 'url-strategy');
    });
  });
}
