import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_common_utils/json_utils.dart';

Future main() async {
  var shell = Shell();

  print(jsonPretty(Platform.environment));
  await shell.run('''
    
ls
  
''');
}
