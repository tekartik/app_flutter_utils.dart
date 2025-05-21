import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/app_widget.dart';
import 'package:tekartik_app_image_flutter/utils/ui_image_generator.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

Widget generatorScreen({ThemeData? themeData}) {
  late ui.Image image;
  late ui.Image placeholderImage;
  return Theme(
    data: themeData ?? ThemeData.light(),
    child: Scaffold(
      appBar: AppBar(title: const Text('Generator')),
      body: FutureBuilder(
        future: () async {
          image = await newUiImageColored(
            color: Colors.red,
            width: 2,
            height: 2,
          );
          placeholderImage = await newUiImagePlaceholder(
            color: Colors.red,
            width: 50,
            height: 50,
          );
          return true;
        }(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CenteredProgress();
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                for (var whs in [(90.0, 160.0), (160.0, 90.0)]) ...[
                  Text('RawImage ${whs.$1}x${whs.$2}'),
                  Wrap(
                    spacing: 16,
                    children: [
                      SizedBox(
                        width: whs.$1,
                        height: whs.$2,
                        child: RawImage(image: image, fit: BoxFit.fill),
                      ),
                      SizedBox(
                        width: whs.$1,
                        height: whs.$2,
                        child: RawImage(image: placeholderImage),
                      ),
                      Wrap(
                        children: [
                          SizedBox(
                            width: whs.$1,
                            height: whs.$2,
                            child: RawImage(
                              image: placeholderImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        children: [
                          SizedBox(
                            width: whs.$1,
                            height: whs.$2,
                            child: RawImage(
                              image: placeholderImage,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        children: [
                          SizedBox(
                            width: whs.$1,
                            height: whs.$2,
                            child: RawImage(
                              image: placeholderImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        children: [
                          SizedBox(
                            width: whs.$1,
                            height: whs.$2,
                            child: RawImage(
                              image: placeholderImage,
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    ),
  );
}

void defineImageMenu() {
  menu('image', () {
    item('Generator', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            return generatorScreen();
          },
        ),
      );
    });
  });
}

void main() {
  platformInit();
  mainMenuFlutter(() {
    defineImageMenu();
  }, showConsole: true);
}
