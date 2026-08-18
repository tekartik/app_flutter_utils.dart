import 'package:flutter/material.dart';
import 'package:tekartik_app_dev_menu_flutter/dev_menu_flutter.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_sdb_ui_test_app_lib/demo_db.dart';
import 'package:tekartik_sdb_ui_test_app_lib/sdb_list_view_page.dart';

Future<void> _push(Widget page) async {
  await navigator.push<void>(MaterialPageRoute(builder: (context) => page));
}

/// Sdb UI test menu.
void defineMenu() {
  menu('sdb_ui', () {
    var demoDb = DemoDb.instance;

    item('record count', () async {
      write('${await demoDb.getCount()} record(s)');
    });
    item('populate 1000 records', () async {
      await demoDb.populate(1000);
      write('${await demoDb.getCount()} record(s)');
    });
    item('populate 20000 records', () async {
      await demoDb.populate(20000);
      write('${await demoDb.getCount()} record(s)');
    });
    item('clear records', () async {
      await demoDb.clear();
      write('${await demoDb.getCount()} record(s)');
    });
    item('delete database', () async {
      await demoDb.deleteDatabase();
      write('deleted');
    });

    item('SdbStoreListView (one shot)', () async {
      await _push(const SdbListViewDemoPage(title: 'Store, one shot'));
    });
    item('SdbStoreListView (watch)', () async {
      await _push(
        const SdbListViewDemoPage(title: 'Store, watched', watch: true),
      );
    });
    item('SdbStoreListView (watch, no page eviction)', () async {
      // Every page scrolled through stays watched and is re-queried on every
      // change: scroll far, start the background writer and compare with the
      // demo above (this is what pageWindowMargin prevents).
      await _push(
        const SdbListViewDemoPage(
          title: 'Store, watched, no eviction',
          watch: true,
          pageWindowMargin: null,
        ),
      );
    });
    item('SdbStoreListView (watch, filtered)', () async {
      await _push(
        const SdbListViewDemoPage(
          title: 'Store, watched, filtered',
          watch: true,
          filtered: true,
        ),
      );
    });
    item('SdbIndexListView (one shot, by name)', () async {
      await _push(
        const SdbListViewDemoPage(
          title: 'Index, one shot',
          source: SdbListSource.nameIndex,
        ),
      );
    });
    item('SdbIndexListView (watch, by name)', () async {
      await _push(
        const SdbListViewDemoPage(
          title: 'Index, watched',
          source: SdbListSource.nameIndex,
          watch: true,
        ),
      );
    });
  });
}

void main() {
  platformInit();
  mainMenuFlutter(() {
    defineMenu();
  }, showConsole: true);
}
