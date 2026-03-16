import 'package:flutter/services.dart';

/// Get the list of assets
Future<List<String>> getAssetList() async {
  final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final assets = assetManifest.listAssets();
  return assets;
}
