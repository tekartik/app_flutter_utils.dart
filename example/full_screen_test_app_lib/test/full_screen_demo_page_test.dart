import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen_memory.dart';
import 'package:tekartik_full_screen_test_app_lib/full_screen_demo_page.dart';

void main() {
  testWidgets('demo page', (tester) async {
    var fullScreen = PlatformFullScreenMemory();
    await tester.pumpWidget(
      MaterialApp(home: FullScreenDemoPage(fullScreen: fullScreen)),
    );
    expect(find.text('supported: true'), findsOneWidget);
    expect(find.text('isFullScreen: false'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);

    await tester.tap(find.text('Enter'));
    await tester.pump();
    expect(fullScreen.requests, [true]);
    expect(find.text('isFullScreen: true'), findsOneWidget);
    expect(find.text('onChanged: true'), findsOneWidget);
    // The app's own full screen: no app bar.
    expect(find.byType(AppBar), findsNothing);

    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(fullScreen.requests, [true, false]);
    expect(find.text('isFullScreen: false'), findsOneWidget);
    expect(find.text('onChanged: false'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);

    // Escape in the browser: not asked for, shown anyway.
    await tester.tap(find.text('Enter'));
    await tester.pump();
    expect(find.text('isFullScreen: true'), findsOneWidget);
    fullScreen.simulateFullScreenChanged(false);
    await tester.pump();
    expect(find.text('isFullScreen: false'), findsOneWidget);
    expect(find.text('onChanged: false'), findsNWidgets(2));
    expect(fullScreen.requests, [true, false, true]);

    // Injected: not disposed by the page.
    await tester.pumpWidget(const SizedBox());
    await fullScreen.setFullScreen(true);
    expect(fullScreen.isFullScreen, isTrue);
    fullScreen.dispose();
  });

  testWidgets('unsupported', (tester) async {
    var fullScreen = PlatformFullScreenMemory(supported: false);
    await tester.pumpWidget(
      MaterialApp(home: FullScreenDemoPage(fullScreen: fullScreen)),
    );
    expect(find.text('supported: false'), findsOneWidget);
    await tester.tap(find.text('Enter'));
    await tester.pump();
    expect(find.text('isFullScreen: false'), findsOneWidget);
    fullScreen.dispose();
  });
}
