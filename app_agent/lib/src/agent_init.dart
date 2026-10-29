import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:tekartik_app_agent/app_agent.dart';

import 'agent_bridge_stub.dart'
    if (dart.library.js_interop) 'agent_bridge_web.dart';

AgentUrlOptions? _options;
var _agentAllowed = false;
SemanticsHandle? _semanticsHandle;
var _bridgeInstalled = false;

/// The agent options read by [agentInit], all off before.
AgentUrlOptions get agentUrlOptions => _options ?? const AgentUrlOptions();

/// Whether [agentInit] let an agent in (`?agent`, with the key in a release
/// build).
bool get agentAllowed => _agentAllowed;

/// Reads the agent options of [uri] (`Uri.base` by default: the page url on
/// the web) and:
///
/// - with `?semantics`, or `?agent` let in, builds the semantics from now
///   on, for the life of the app: on the web the semantics DOM exists from
///   the first frame, with its `flt-semantics-identifier` ids, without the
///   "enable accessibility" button;
/// - with `?agent` let in on the web, installs the js bridge of [commands]
///   ([agentCommands] by default): `window.tekartikAgent`
///   ([agentBridgeName]) with `commands()` and `run(name, args)`. `?agent`
///   lets an agent in (the default), except in a release build given
///   [releaseKey] (the `AgentKey` of the app, from the generated agent
///   constants of its project, checked only when the url has `?agent`):
///   it asks `?agent=<key>`;
/// - in a debug or profile run, registers the VM service extensions of
///   [commands] (`ext.tekartik.agent.commands`, `ext.tekartik.agent.run`).
///
/// The commands are the ones registered at call time ([AgentCommandsScope],
/// [AgentCommands.add]), read on each call.
///
/// Call it once the binding is initialized
/// (`WidgetsFlutterBinding.ensureInitialized()`), before `runApp`. Returns
/// the options (also [agentUrlOptions]).
AgentUrlOptions agentInit({
  Uri? uri,
  AgentCommands? commands,
  AgentKey? releaseKey,
}) {
  var options = _options = AgentUrlOptions.fromUri(uri ?? Uri.base);
  commands ??= agentCommands;
  var allowed = _agentAllowed = options.agentAllowed(
    release: kReleaseMode,
    releaseKey: () => releaseKey,
  );
  if (options.semantics || allowed) {
    _semanticsHandle ??= SemanticsBinding.instance.ensureSemantics();
  }
  if (allowed && kIsWeb && !_bridgeInstalled) {
    _bridgeInstalled = true;
    agentBridgeInstall(commands);
  }
  if (!kReleaseMode) {
    agentVmRegister(commands);
  }
  return options;
}
