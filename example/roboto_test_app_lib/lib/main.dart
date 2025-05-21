import 'package:flutter/material.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_roboto/app_roboto.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

Widget robotoScreen({ThemeData? themeData}) {
  return Theme(
    data: themeData ?? ThemeData.light(),
    child: Builder(
      builder: (context) {
        var textTheme = themeData?.textTheme ?? TextTheme.of(context);
        return Scaffold(
          appBar: AppBar(title: const Text('Generator')),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AllTypography(textTheme: textTheme),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class AllTypography extends StatelessWidget {
  const AllTypography({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(),

        /// Generate all typography text elements
        Text('Title Large', style: textTheme.titleLarge),
        Text('Title Medium', style: textTheme.titleMedium),
        Text('Title Small', style: textTheme.titleSmall),
        Text('Label Large', style: textTheme.labelLarge),
        Text('Label Medium', style: textTheme.labelMedium),
        Text('Label Small', style: textTheme.labelSmall),
        Text('Body Large', style: textTheme.bodyLarge),
        Text('Body Medium', style: textTheme.bodyMedium),
        Text('Body Small', style: textTheme.bodySmall),
        Text('Display Large', style: textTheme.displayLarge),
        Text('Display Medium', style: textTheme.displayMedium),
        Text('Display Small', style: textTheme.displaySmall),
        Text('Headline Large', style: textTheme.headlineLarge),
        Text('Headline Medium', style: textTheme.headlineMedium),
        Text('Headline Small', style: textTheme.headlineSmall),
        Text('Label Large', style: textTheme.labelLarge),
        Text('Label Medium', style: textTheme.labelMedium),
        Text('Label Small', style: textTheme.labelSmall),
        const Text('0123456789'),
        const Text('0123456789', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

void defineRobotoMenu() {
  menu('roboto', () {
    item('Default', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            return robotoScreen();
          },
        ),
      );
    });
    item('Roboto', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            var themeData = ThemeData(
              brightness: Brightness.light,
              fontFamily: robotoFontFamily,
            );
            return robotoScreen(themeData: themeData);
          },
        ),
      );
    });
    item('Roboto Condensed', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            var themeData = ThemeData(
              brightness: Brightness.light,
              fontFamily: robotoCondensedFontFamily,
            );
            return robotoScreen(themeData: themeData);
          },
        ),
      );
    });
    item('Roboto Mono', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            var themeData = ThemeData(
              brightness: Brightness.light,
              fontFamily: robotoMonoFontFamily,
            );

            return robotoScreen(themeData: themeData);
          },
        ),
      );
    });
  });
}

void main() {
  platformInit();
  mainMenuFlutter(() {
    defineRobotoMenu();
  }, showConsole: true);
}
