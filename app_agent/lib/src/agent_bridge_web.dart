import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_app_agent/app_agent.dart';

const _help =
    'The commands of this app. $agentBridgeName.commands(): their '
    'descriptions (name, description, inputSchema). '
    '$agentBridgeName.run(name, args): a promise of {ok: true, result} or '
    '{ok: false, error}, args an object (or its json).';

/// Installs `window.tekartikAgent` ([agentBridgeName]) running [commands]:
/// `commands()`, `run(name, args)` (a promise), `help()`.
void agentBridgeInstall(AgentCommands commands) {
  var bridge = JSObject();
  bridge['commands'] = (() => commands.describe().jsify()).toJS;
  bridge['run'] = ((JSString name, JSAny? args) {
    return (() async {
      Map<String, Object?>? map;
      var dartArgs = args?.dartify();
      if (dartArgs is String && dartArgs.isNotEmpty) {
        dartArgs = jsonDecode(dartArgs);
      }
      if (dartArgs is Map) {
        map = dartArgs.cast<String, Object?>();
      }
      var result = await commands.run(name.toDart, map);
      return result.toJson().jsify();
    })().toJS;
  }).toJS;
  bridge['help'] = (() => _help.toJS).toJS;
  globalContext[agentBridgeName] = bridge;
}
