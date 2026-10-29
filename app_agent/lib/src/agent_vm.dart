import 'dart:convert';
import 'dart:developer';

import 'package:tekartik_app_agent/app_agent.dart';

/// The VM service extension listing the commands.
const agentVmCommandsExtension = 'ext.tekartik.agent.commands';

/// The VM service extension running a command (`name`, `args` as json).
const agentVmRunExtension = 'ext.tekartik.agent.run';

var _registered = false;

/// Registers the VM service extensions of [commands] (once): reachable from
/// the Dart tooling of a debug or profile run (the Dart MCP server, DTD,
/// `callServiceExtension`).
void agentVmRegister(AgentCommands commands) {
  if (_registered) {
    return;
  }
  _registered = true;
  registerExtension(agentVmCommandsExtension, (method, parameters) async {
    return ServiceExtensionResponse.result(
      jsonEncode({'commands': commands.describe()}),
    );
  });
  registerExtension(agentVmRunExtension, (method, parameters) async {
    var name = parameters['name'];
    if (name == null) {
      return ServiceExtensionResponse.error(
        ServiceExtensionResponse.invalidParams,
        'missing name',
      );
    }
    Map<String, Object?>? args;
    var argsText = parameters['args'];
    if (argsText != null && argsText.isNotEmpty) {
      args = (jsonDecode(argsText) as Map).cast<String, Object?>();
    }
    var result = await commands.run(name, args);
    return ServiceExtensionResponse.result(jsonEncode(result.toJson()));
  });
}
