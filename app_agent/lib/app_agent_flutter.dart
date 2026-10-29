/// Flutter helpers for the apps an agent (an LLM, a test tool) drives:
///
/// - [AgentId]: a stable id on a widget (`Semantics(identifier:)`), the
///   Android `resource-id`, the iOS `accessibilityIdentifier`, the web
///   `flt-semantics-identifier`;
/// - [agentInit]: reads the [AgentUrlOptions] of the page url, builds the
///   semantics from the start when they ask for it (`?semantics`,
///   `?agent`), exposes the [agentCommands] (the web js bridge with
///   `?agent`, `?agent=<key>` in a release build: [AgentKey], VM service
///   extensions in debug);
/// - [AgentCommandsScope]: registers commands while in the tree.
library;

export 'package:tekartik_app_agent/app_agent.dart'
    show
        AgentCommand,
        AgentCommandException,
        AgentCommandResult,
        AgentCommands,
        AgentCommandsRegistration,
        AgentKey,
        AgentSchema,
        AgentUrlOptions,
        agentBridgeName,
        agentCommands,
        agentVmCommandsExtension,
        agentVmRunExtension;

export 'src/agent_commands_scope.dart' show AgentCommandsScope;
export 'src/agent_id.dart' show AgentId;
export 'src/agent_init.dart' show agentAllowed, agentInit, agentUrlOptions;
