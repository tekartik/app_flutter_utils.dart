import 'package:tekartik_app_flutter_fs/fs.dart';
import 'package:tekartik_test_menu/test.dart';

void main() {
  menu('fs', () {
    item('getApplicationDocumentsDirectory', () async {
      write(await fs.getApplicationDocumentsDirectory());
    });
  });
}
