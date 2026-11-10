// The lib/main.dart of a Flutter app depending on
// tekartik_app_dev_menu_flutter (any platform), `flutter run`.
import 'package:tekartik_app_dev_menu_flutter/dev_menu_flutter.dart';

/// The menu, in a function: a test or a CLI can declare it too.
void defineMenu() {
  menu('demo', () {
    var count = 0;
    enter(() => write('entering demo'));
    leave(() => write('leaving demo'));
    item('write', () => write('Hello at ${DateTime.now()}'));
    item('count', () => write('count ${++count}'));
    item('prompt', () async {
      var name = await prompt('Your name');
      write('Hi $name');
    });
    menu('sub', () {
      item('async', () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        write('done after 500 ms');
      });
    });
  });
  item('throws', () => throw StateError('shown in the console'));
}

void main() {
  mainMenuFlutter(defineMenu);
}
