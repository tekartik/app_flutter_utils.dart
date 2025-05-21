import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_navigator_flutter/route_aware.dart';
import 'package:tekartik_app_navigator_flutter/src/import.dart';

import 'route_aware_test.dart';

var homePageDef = ContentPageDef(
  screenBuilder: (_) {
    return HomeScreen();
  },
  path: rootContentPath,
);
ContentPageDef namedPageDef(String name) => ContentPageDef(
  screenBuilder: (_) {
    return TestNamedScreen(name: name);
  },
  path: ContentPath.fromString('named/$name'),
);

class HomeScreen extends TestNamedScreen {
  HomeScreen({super.key}) : super(name: '/');

  @override
  RouteAwareState<HomeScreen> createState() => HomeScreenState();
}

class TestNamedScreen extends RouteAwareStatefulWidget {
  final String name;
  TestNamedScreen({super.key, required this.name})
    : super(contentPath: ContentPath.fromString(name));

  @override
  RouteAwareState<TestNamedScreen> createState() => _TestNamedScreenState();
}

class _TestNamedScreenState<T extends TestNamedScreen>
    extends RouteAwareState<T> {
  String get name => widget.name;

  @override
  void initState() {
    homeScreenState = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  void onResume() {
    testAddEvent(TestEvent(TestEventType.resume, name));
    Future.delayed(Duration.zero, () {
      testAddEvent(TestEvent(TestEventType.resume, '$name 0'));
    });
    super.onResume();
  }

  @override
  void onPause() {
    testAddEvent(TestEvent(TestEventType.pause, name));
    super.onPause();
  }
}

void testAddEvent(TestEvent event) {
  testEventController.add(event);
}

class TestEventHandler {
  final int count;
  final WidgetTester tester;
  final ContentNavigator cn;
  late final Future<List<TestEvent>> _events;
  Future<List<TestEvent>> pumpAndGetEvents() async {
    await tester.pumpWidget(cn);

    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    return _events;
  }

  //late StreamSubscription _subscription;
  TestEventHandler(this.tester, this.cn, this.count) {
    _events = testEventStream.take(count).toList().then((list) {
      //_subscription.cancel();
      return list;
    });
    /*_subscription = testEventStream.listen((event) {
      print('Debug event $event');
    });*/
  }
}

late State homeScreenState;

class HomeScreenState extends _TestNamedScreenState<HomeScreen> {}

final contentNavigatorDef = ContentNavigatorDef(
  defs: [homePageDef, namedPageDef('a')],
);

Stream<TestEvent> get testEventStream => testEventController.stream;
late StreamController<TestEvent> testEventController;
void main() {
  contentNavigatorDebug = true;
  late ContentNavigator cn;
  setUp(() async {
    testEventController = StreamController.broadcast();
    cn = ContentNavigator(
      // Needed for onResume/onPause
      observers: [routeAwareObserver],
      def: contentNavigatorDef,
      child: Builder(
        builder: (context) {
          var cn = ContentNavigator.of(context);
          return MaterialApp.router(
            title: 'Stable app',

            routerDelegate: cn.routerDelegate,
            routeInformationParser: cn.routeInformationParser,
            // routeInformationProvider: _platformRouteInformationProvider, // if uncomment we always start on the initial route
          );
        },
      ),
    );
  });
  tearDown(() {
    testEventController.close();
  });
  group('route_aware_timing', () {
    testWidgets('initial_route', (WidgetTester tester) async {
      var future = testEventStream.take(2).toList();
      await tester.pumpWidget(cn);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(await future, [
        TestEvent(TestEventType.resume, '/'),
        TestEvent(TestEventType.resume, '/ 0'),
      ]);

      //await expectLater(stream, emits([]));
    });
    testWidgets('push pop', (WidgetTester tester) async {
      var future = testEventStream.take(5).toList();
      await tester.pumpWidget(cn);
      var context = homeScreenState.context;
      Navigator.of(context)
          .push<void>(
            MaterialPageRoute(
              builder: (_) {
                return TestNamedScreen(name: 'pushed');
              },
            ),
          )
          .unawait();
      await tester.pumpWidget(cn);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(await future, [
        TestEvent(TestEventType.resume, '/'),
        TestEvent(TestEventType.pause, '/'),
        TestEvent(TestEventType.resume, 'pushed'),
        TestEvent(TestEventType.resume, '/ 0'),
        TestEvent(TestEventType.resume, 'pushed 0'),
      ]);

      future = testEventStream.take(2).toList();
      Navigator.of(context).pop();
      await tester.pumpWidget(cn);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(await future, [
        TestEvent(TestEventType.pause, 'pushed'),
        TestEvent(TestEventType.resume, '/'),
      ]);
    });
    Future<BuildContext> initAndPushHome(WidgetTester tester) async {
      var future = testEventStream.take(2).toList();
      await tester.pumpWidget(cn);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      var context = homeScreenState.context;
      expect(await future, [
        TestEvent(TestEventType.resume, '/'),
        TestEvent(TestEventType.resume, '/ 0'),
      ]);
      return context;
    }

    Future<BuildContext> initAndPushHomeThenPushed(WidgetTester tester) async {
      var context = await initAndPushHome(tester);
      final handler = TestEventHandler(tester, cn, 3);
      Navigator.of(context)
          .push<void>(
            MaterialPageRoute(
              builder: (_) {
                return TestNamedScreen(name: 'pushed');
              },
            ),
          )
          .unawait();
      expect(await handler.pumpAndGetEvents(), [
        TestEvent(TestEventType.pause, '/'),
        TestEvent(TestEventType.resume, 'pushed'),
        TestEvent(TestEventType.resume, 'pushed 0'),
      ]);
      return context;
    }

    testWidgets('pop push', (WidgetTester tester) async {
      var context = await initAndPushHomeThenPushed(tester);

      var handler = TestEventHandler(tester, cn, 5);
      Navigator.of(context).pop();
      Navigator.of(context)
          .push<void>(
            MaterialPageRoute(
              builder: (_) {
                return TestNamedScreen(name: 'pushed');
              },
            ),
          )
          .unawait();

      expect(await handler.pumpAndGetEvents(), [
        TestEvent(TestEventType.pause, 'pushed'),
        TestEvent(TestEventType.resume, '/'),
        TestEvent(TestEventType.resume, 'pushed'),
        TestEvent(TestEventType.resume, '/ 0'),
        TestEvent(TestEventType.resume, 'pushed 0'),
      ]);
    });

    testWidgets('transient pop push', (WidgetTester tester) async {
      var context = await initAndPushHomeThenPushed(tester);
      var handler = TestEventHandler(tester, cn, 3);
      ContentNavigator.transientPop(context);
      Navigator.of(context)
          .push<void>(
            MaterialPageRoute(
              builder: (_) {
                return TestNamedScreen(name: 'pushed');
              },
            ),
          )
          .unawait();

      expect(await handler.pumpAndGetEvents(), [
        TestEvent(TestEventType.pause, 'pushed'),
        TestEvent(TestEventType.resume, 'pushed'),
        TestEvent(TestEventType.resume, 'pushed 0'),
      ]);
    });

    testWidgets('transient until pop push', (WidgetTester tester) async {
      var context = await initAndPushHomeThenPushed(tester);
      var handler = TestEventHandler(tester, cn, 3);
      ContentNavigator.transientPopUntilPath(
        context,
        ContentPath.fromString('/'),
      );

      Navigator.of(context)
          .push<void>(
            MaterialPageRoute(
              builder: (_) {
                return TestNamedScreen(name: 'pushed');
              },
              settings: const RouteSettings(name: 'pushed'),
            ),
          )
          .unawait();
      expect(await handler.pumpAndGetEvents(), [
        TestEvent(TestEventType.pause, 'pushed'),
        TestEvent(TestEventType.resume, 'pushed'),
        TestEvent(TestEventType.resume, 'pushed 0'),
      ]);
    });
  });
}
