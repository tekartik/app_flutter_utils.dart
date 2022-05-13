import 'package:tekartik_app_flutter_plugin/monkey.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_test_menu/test.dart';

void main() {
  menu('monkey', () {
    Timer? timer;
    item('start checking isMonkeyRunning every 500ms', () async {
      timer?.cancel();
      timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
        write('monkey running ${await isMonkeyRunning}');
      });
    });
    item('stop', () async {
      timer?.cancel();
    });
  });
}
