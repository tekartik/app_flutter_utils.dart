import 'dart:convert';

import 'package:flutter/services.dart';

/// Get the list of assets
Future<List<String>> getAssetList() async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');

  final manifestMap = jsonDecode(manifestContent) as Map;
  return manifestMap.keys.cast<String>().toList();
}
