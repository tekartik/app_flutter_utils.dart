import 'package:flutter/services.dart';
import 'package:tekartik_app_common_utils/asset/asset_bundle.dart';

/// Flutter implementation of [TkRootBundle]
abstract class TkAssetBundleFlutter implements TkAssetBundle {
  /// Create a [TkAssetBundleFlutter] from an [assetBundle]
  factory TkAssetBundleFlutter(AssetBundle assetBundle) =>
      _TkAssetBundleFlutter(assetBundle);
}

/// Flutter implementation of [TkRootBundle]
class _TkAssetBundleFlutter implements TkAssetBundleFlutter {
  final AssetBundle assetBundle;

  _TkAssetBundleFlutter(this.assetBundle);
  @override
  Future<String> loadString(String key) async {
    return assetBundle.loadString(key);
  }

  @override
  Future<ByteData> loadByteData(String key) async {
    return assetBundle.load(key);
  }

  @override
  Future<Uint8List> loadBytes(String key) async {
    return Uint8List.sublistView(await loadByteData(key));
  }
}

/// Flutter root bundle
TkAssetBundle tkRootBundle = _TkAssetBundleFlutter(rootBundle);
