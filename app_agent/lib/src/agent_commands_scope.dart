import 'package:flutter/widgets.dart';
import 'package:tekartik_app_agent/app_agent.dart';

/// Registers [commands] in [agentCommands] (or [registry]) while it is in
/// the tree: a screen, an app root, a scope with its context (a router, a
/// database) exposes what it can do. Rebuilt with other commands, it
/// replaces them.
class AgentCommandsScope extends StatefulWidget {
  /// The commands.
  final List<AgentCommand> commands;

  /// The registry, [agentCommands] by default.
  final AgentCommands? registry;

  /// The widget below.
  final Widget child;

  /// Registers [commands] while in the tree.
  const AgentCommandsScope({
    super.key,
    required this.commands,
    this.registry,
    required this.child,
  });

  @override
  State<AgentCommandsScope> createState() => _AgentCommandsScopeState();
}

class _AgentCommandsScopeState extends State<AgentCommandsScope> {
  late AgentCommandsRegistration _registration;

  AgentCommands get _registry => widget.registry ?? agentCommands;

  @override
  void initState() {
    super.initState();
    _registration = _registry.add(widget.commands);
  }

  @override
  void didUpdateWidget(AgentCommandsScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registration.remove();
    _registration = _registry.add(widget.commands);
  }

  @override
  void dispose() {
    _registration.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
