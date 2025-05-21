// ignore: depend_on_referenced_packages
import 'package:tekartik_app_flutter_fs/fs.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_test_menu/test.dart';

void main() {
  menu('fs', () {
    item('getApplicationDocumentsDirectory', () async {
      write(
        await fs.getApplicationDocumentsDirectory(
          packageName: 'test.tekartik.com',
        ),
      );
    });
  });
}
