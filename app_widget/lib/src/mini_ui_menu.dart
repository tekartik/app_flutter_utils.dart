import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_utils/common_utils_import.dart';

class MuiMenuContext {}

class _MuiMenuContext implements MuiMenuContext {
  final _MuiMenuContext? parent;
  final List<MuiItem> items = [];
  _MuiMenuContext({this.parent});
}

_MuiMenuContext? _context;
BuildContext? _muiBuildContext;
BuildContext get muiBuildContext {
  assert(_muiBuildContext != null,
      'muiBuildContext must be called in a muiMenu context');
  return _muiBuildContext!;
}

Future<T?> showMuiMenu<T>(
    BuildContext context, String name, void Function() body) async {
  var muiMenuContext = muiMenu(name, body) as _MuiMenuContext;
  var result =
      await Navigator.of(context).push<Object?>(MaterialPageRoute(builder: (_) {
    return MuiScreenWidget(name: name, items: muiMenuContext.items);
  }));
  return castAsOrNull<T>(result);
}

void muiItem(String name, void Function() body) {
  assert(_context != null, 'muiItem must be called in a muiMenu context');
  _context!.items.add(MuiItem(name, body));
}

MuiScreenWidget muiScreenWidget(String name, void Function() body) {
  var muiMenuContext = muiMenu(name, body) as _MuiMenuContext;
  return MuiScreenWidget(name: name, items: muiMenuContext.items);
}

MuiMenuContext muiMenu(String name, void Function() body) {
  var parent = _context;
  try {
    if (parent != null) {
      muiItem(name, () {
        showMuiMenu<Object?>(muiBuildContext, name, body).unawait();
      });
      return parent;
    } else {
      var context = _context = _MuiMenuContext(parent: parent);
      body();
      return context;
    }
  } finally {
    _context = parent;
  }
}

class MuiItem {
  final String name;
  final VoidCallback callback;

  MuiItem(this.name, this.callback);
}

class MuiScreenWidget extends StatefulWidget {
  final MuiMenuContext? context;
  final String name;
  final List<MuiItem> items;
  const MuiScreenWidget(
      {super.key, required this.items, required this.name, this.context});

  @override
  State<MuiScreenWidget> createState() => _MuiScreenWidgetState();
}

class _MuiScreenWidgetState extends State<MuiScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.name)),
        body: ListView(children: [
          for (var item in widget.items)
            ListTile(
              title: Text(item.name),
              onTap: () {
                _muiBuildContext = context;
                item.callback();
              },
            )
        ]));
  }
}
