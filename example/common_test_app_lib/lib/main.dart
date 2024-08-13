import 'package:tekartik_app_flutter_common_utils/asset/asset_utils.dart';
import 'package:tekartik_app_flutter_common_utils/common_utils_import.dart';
import 'package:tekartik_test_menu_flutter/test.dart';

void defineMenu() {
  menu('common', () {
    item('debugEnvMap', () {
      write(jsonPretty(debugEnvMap));
    });
    item('list assets', () async {
      for (var asset in await getAssetList()) {
        write(asset);
      }
    });
  });
}
