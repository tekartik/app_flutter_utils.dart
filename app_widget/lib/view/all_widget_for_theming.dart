import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tekartik_app_flutter_widget/app_widget.dart';
import 'package:tekartik_app_flutter_widget/view/busy_indicator.dart';

class AllWidgetForTheming extends StatelessWidget {
  const AllWidgetForTheming({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = TextTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Samples of all widgets available (cupertino and materials) to easily test theming
        Text('Display Large', style: textTheme.displayLarge),
        Text('Display Medium', style: textTheme.displayMedium),
        Text('Display Small', style: textTheme.displaySmall),
        Text('Headline Medium', style: textTheme.headlineMedium),
        Text('Headline Small', style: textTheme.headlineSmall),
        Text('Title Large', style: textTheme.titleLarge),
        Text('Title Medium', style: textTheme.titleMedium),
        Text('Title Small', style: textTheme.titleSmall),
        Text('Body Large', style: textTheme.bodyLarge),
        Text('Body Medium', style: textTheme.bodyMedium),
        Text('Body Small', style: textTheme.bodySmall),
        Text('Label Large', style: textTheme.labelLarge),
        Text('Label Medium', style: textTheme.labelMedium),
        Text('Label Small', style: textTheme.labelSmall),
        BusyIndicator(busy: BehaviorSubject.seeded(true)),
        const CenteredProgress(),
        const Card(
          child: Padding(padding: EdgeInsets.all(8.0), child: Text('Card')),
        ),
        ElevatedButton(onPressed: () {}, child: const Text('ElevatedButton')),
        const ElevatedButton(
          onPressed: null,
          child: Text('ElevatedButton disabled'),
        ),
        TextButton(onPressed: () {}, child: const Text('TextButton')),
        const TextButton(onPressed: null, child: Text('TextButton disabled')),
        FloatingActionButton(onPressed: () {}, child: const Icon(Icons.person)),
        const FloatingActionButton(onPressed: null, child: Icon(Icons.person)),
        Checkbox(value: true, onChanged: (bool? value) {}),
        Checkbox(value: false, onChanged: (bool? value) {}),
        Switch(value: true, onChanged: (bool value) {}),
        Switch(value: false, onChanged: (bool value) {}),
        Slider(value: 0.5, onChanged: (double value) {}),
        const CircularProgressIndicator(),
        const LinearProgressIndicator(),
        const Icon(Icons.star),
        const IconButton(icon: Icon(Icons.star), onPressed: null),
        const ListTile(leading: Icon(Icons.list), title: Text('ListTile')),
        const Divider(),
        const Tooltip(message: 'Tooltip', child: Text('Hover over me')),
        const SizedBox(height: 20),
        AppBar(title: const Text('App bar')),
        BottomAppBar(
          child: Row(
            children: [
              const Text('BottomAppBar'),
              IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ],
          ),
        ),
        AlertDialog(
          title: const Text('AlertDialog'),
          content: const Text('This is an alert dialog'),
          actions: [TextButton(onPressed: () {}, child: const Text('OK'))],
        ),
      ],
    );
  }
}
