/// Flutter helpers for the apps an agent (an LLM, a test tool) drives:
///
/// - [AgentId]: a stable id on a widget (`Semantics(identifier:)`), the
///   Android `resource-id`, the iOS `accessibilityIdentifier`, the web
///   `flt-semantics-identifier`;
/// - [agentInit]: reads the [AgentUrlOptions] of the page url and builds the
///   semantics from the start when they ask for it (`?semantics`,
///   `?agent`).
library;

export 'package:tekartik_app_agent/app_agent.dart' show AgentUrlOptions;

export 'src/agent_id.dart' show AgentId;
export 'src/agent_init.dart' show agentInit, agentUrlOptions;
