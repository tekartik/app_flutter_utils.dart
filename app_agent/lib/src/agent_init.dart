import 'package:flutter/semantics.dart';
import 'package:tekartik_app_agent/app_agent.dart';

AgentUrlOptions? _options;
SemanticsHandle? _semanticsHandle;

/// The agent options read by [agentInit], all off before.
AgentUrlOptions get agentUrlOptions => _options ?? const AgentUrlOptions();

/// Reads the agent options of [uri] (`Uri.base` by default: the page url on
/// the web) and, when they ask for it (`?semantics`, `?agent`), builds the
/// semantics from now on, for the life of the app: on the web the semantics
/// DOM exists from the first frame, with its `flt-semantics-identifier`
/// ids, without the "enable accessibility" button.
///
/// Call it once the binding is initialized
/// (`WidgetsFlutterBinding.ensureInitialized()`), before `runApp`. Returns
/// the options (also [agentUrlOptions]).
AgentUrlOptions agentInit({Uri? uri}) {
  var options = _options = AgentUrlOptions.fromUri(uri ?? Uri.base);
  if (options.needsSemantics) {
    _semanticsHandle ??= SemanticsBinding.instance.ensureSemantics();
  }
  return options;
}
