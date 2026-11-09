import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_app_agent/app_agent.dart';

const _help =
    'The commands of this app. $agentBridgeName.commands(): their '
    'descriptions (name, description, inputSchema). '
    '$agentBridgeName.run(name, args): a promise of {ok: true, result} or '
    '{ok: false, error}, args an object (or its json).';

@JS('JSON.stringify')
external JSString? _jsonStringify(JSAny? value);

/// [args] (an object, or its json) as the VM service extension reads them:
/// decoded from json, so that a command gets the same Dart types on every
/// compiler (`dartify` gives a double for every number on dart2wasm, and
/// `Map<Object?, Object?>` for the nested objects).
Map<String, Object?>? _runArgs(JSAny? args) {
  if (args == null) {
    return null;
  }
  var json = args.isA<JSString>()
      ? (args as JSString).toDart
      : _jsonStringify(args)?.toDart;
  if (json == null || json.isEmpty) {
    return null;
  }
  var decoded = jsonDecode(json);
  return decoded is Map ? decoded.cast<String, Object?>() : null;
}

/// Installs `window.tekartikAgent` ([agentBridgeName]) running [commands]:
/// `commands()`, `run(name, args)` (a promise), `help()`.
void agentBridgeInstall(AgentCommands commands) {
  var bridge = JSObject();
  bridge['commands'] = (() => commands.describe().jsify()).toJS;
  bridge['run'] = ((JSString name, JSAny? args) {
    return (() async {
      var map = _runArgs(args);
      var result = await commands.run(name.toDart, map);
      return result.toJson().jsify();
    })().toJS;
  }).toJS;
  bridge['help'] = (() => _help.toJS).toJS;
  globalContext[agentBridgeName] = bridge;
}
