import 'package:flutter/foundation.dart';
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
  assert(
    _muiBuildContext != null,
    'muiBuildContext must be called in a muiMenu context',
  );
  return _muiBuildContext!;
}

Future<T?> showMuiMenu<T>(
  BuildContext context,
  String name,
  void Function() body,
) async {
  var muiMenuContext = muiMenu(name, body) as _MuiMenuContext;
  var result = await Navigator.of(context).push<Object?>(
    MaterialPageRoute(
      builder: (_) {
        return MuiScreenWidget(name: name, items: muiMenuContext.items);
      },
    ),
  );
  return castAsOrNull<T>(result);
}

void muiItem(String name, void Function() body, {@doNotSubmit bool? solo}) {
  assert(_context != null, 'muiItem must be called in a muiMenu context');
  _context!.items.add(MuiItem(name, body, solo: solo ?? false));
}

MuiScreenWidget muiScreenWidget(String name, void Function() body) {
  var muiMenuContext = muiMenu(name, body) as _MuiMenuContext;
  return MuiScreenWidget(name: name, items: muiMenuContext.items);
}

MuiBodyWidget muiBodyWidget(void Function() body, {bool? shrinkWrap}) {
  var muiMenuContext = muiMenu('body', body) as _MuiMenuContext;
  return MuiBodyWidget(items: muiMenuContext.items, shinkWrap: true);
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

/// Signature of callbacks that have no arguments and return no data.
typedef MuiFutureOrVoidCallback = FutureOr<void> Function();

/// Simple item
class MuiItem {
  final String name;
  final MuiFutureOrVoidCallback callback;
  final bool solo;

  MuiItem(this.name, this.callback, {this.solo = false});
}

class MuiScreenWidget extends StatefulWidget {
  final MuiMenuContext? context;
  final String name;
  final List<MuiItem> items;

  const MuiScreenWidget({
    super.key,
    required this.items,
    required this.name,
    this.context,
  });

  @override
  State<MuiScreenWidget> createState() => _MuiScreenWidgetState();
}

class _MuiScreenWidgetState extends State<MuiScreenWidget> {
  @override
  void initState() {
    /// Auto start solo item if any
    sleep(0).then((_) async {
      for (var item in widget.items) {
        if (item.solo) {
          if (kDebugMode) {
            print('running solo ${item.name}');
          }
          if (mounted) {
            _muiBuildContext = context;
            await item.callback();
          }
        }
      }
    });

    /// Handle solo
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: ListView(
        children: [
          for (var item in widget.items)
            ListTile(
              title: Text(item.name),
              onTap: () {
                _muiBuildContext = context;
                item.callback();
              },
            ),
        ],
      ),
    );
  }
}

class MuiBodyWidget extends StatefulWidget {
  /// Optional parent context.
  final MuiMenuContext? context;
  final bool? shinkWrap;

  final List<MuiItem> items;

  const MuiBodyWidget({
    super.key,
    required this.items,
    this.context,
    this.shinkWrap,
  });

  @override
  State<MuiBodyWidget> createState() => _MuiBodyWidgetState();
}

class _MuiBodyWidgetState extends State<MuiBodyWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: widget.shinkWrap ?? false,
      children: [
        for (var item in widget.items)
          ListTile(
            title: Text(item.name),
            onTap: () {
              _muiBuildContext = context;
              item.callback();
            },
          ),
      ],
    );
  }
}
