import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_navigator_flutter/route_aware.dart';
import 'package:tekartik_app_navigator_flutter/src/import.dart';

var homePageDef = ContentPageDef(
  screenBuilder: (_) {
    return const HomeScreen();
  },
  path: rootContentPath,
);
ContentPageDef namedPageDef(String name) => ContentPageDef(
  screenBuilder: (_) {
    return TestNamedScreen(name: name);
  },
  path: ContentPath.fromString('named/$name'),
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class TestNamedScreen extends StatefulWidget {
  final String name;
  const TestNamedScreen({super.key, required this.name});

  @override
  State<TestNamedScreen> createState() => _TestNamedScreenState();
}

class _TestNamedScreenState extends RouteAwareStateBase<TestNamedScreen> {
  String get name => widget.name;
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  void onResume() {
    testAddEvent(TestEvent(TestEventType.resume, name));
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

late HomeScreenState homeScreenState;

class HomeScreenState extends RouteAwareState<HomeScreen> {
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
    testAddEvent(TestEvent(TestEventType.resume, 'home'));
    super.onResume();
  }

  @override
  void onPause() {
    testAddEvent(TestEvent(TestEventType.pause, 'home'));
    super.onPause();
  }
}

final contentNavigatorDef = ContentNavigatorDef(
  defs: [homePageDef, namedPageDef('a')],
);

enum TestEventType { resume, pause }

class TestEvent {
  final String name;
  final TestEventType type;

  TestEvent(this.type, this.name);

  @override
  int get hashCode => name.hashCode + type.hashCode;
  @override
  String toString() {
    return 'TestEvent($type, $name)';
  }

  @override
  bool operator ==(Object other) {
    if (other is TestEvent) {
      if (other.name != name) {
        return false;
      }
      if (other.type != type) {
        return false;
      }
      return true;
    }
    return false;
  }
}

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
  group('route_aware', () {
    testWidgets('initial_route', (WidgetTester tester) async {
      var future = testEventStream.take(1).toList();
      await tester.pumpWidget(cn);
      expect(await future, [TestEvent(TestEventType.resume, 'home')]);

      //await expectLater(stream, emits([]));
    });
    testWidgets('push pop', (WidgetTester tester) async {
      var future = testEventStream.take(1).toList();
      await tester.pumpWidget(cn);

      expect(await future, [TestEvent(TestEventType.resume, 'home')]);
      var context = homeScreenState.context;
      future = testEventStream.take(2).toList();
      Navigator.of(context)
          .push<void>(
            MaterialPageRoute(
              builder: (_) {
                return const TestNamedScreen(name: 'pushed');
              },
            ),
          )
          .unawait();
      await tester.pumpWidget(cn);
      expect(await future, [
        TestEvent(TestEventType.pause, 'home'),
        TestEvent(TestEventType.resume, 'pushed'),
      ]);

      future = testEventStream.take(2).toList();
      Navigator.of(context).pop();
      await tester.pumpWidget(cn);

      expect(await future, [
        TestEvent(TestEventType.resume, 'home'),
        TestEvent(TestEventType.pause, 'pushed'),
      ]);
    });
  });
}
