import 'package:flutter/material.dart';
import 'package:tekartik_test_menu_flutter/test.dart';

void menuAppScrollBehavior() {
  menu('scroll_behavior', () {
    item('Desktop test', () async {
      await navigator.push<Object?>(
        MaterialPageRoute(builder: (_) => const AppScrollBehaviorScreen()),
      );
    });
  });
}

class AppScrollBehaviorScreen extends StatelessWidget {
  const AppScrollBehaviorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Scroll Behavior')),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(seconds: 2));
        },
        child: ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) {
            return ListTile(title: Text('Item $index'));
          },
        ),
      ),
    );
  }
}
