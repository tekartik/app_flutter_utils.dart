import 'dart:io';

import 'travis_flutter_install.dart';

Future main() async {
  // We write the path to be sourced
  stdout.write(await travisCreateEnvFile());
}
