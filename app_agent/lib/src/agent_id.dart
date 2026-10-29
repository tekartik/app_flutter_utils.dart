import 'package:flutter/widgets.dart';

/// Gives [child] the stable automation [id]: the Android `resource-id`, the
/// iOS `accessibilityIdentifier`, the web `flt-semantics-identifier`. Ids do
/// not depend on the locale nor the wording: keep them in one constants file
/// per app, shared with its tools.
///
/// A control (a button, a tile, a text) is merged into one node with its
/// label and its action, so that tapping the id taps the control. A
/// [container] (a row of buttons, a list) keeps its children as nodes of
/// their own, each with its id.
class AgentId extends StatelessWidget {
  /// The id.
  final String id;

  /// True for a group of controls, see [AgentId].
  final bool container;

  /// The identified widget.
  final Widget child;

  /// Gives [child] the [id].
  const AgentId(
    this.id, {
    super.key,
    this.container = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (container) {
      return Semantics(container: true, identifier: id, child: child);
    }
    return MergeSemantics(
      child: Semantics(identifier: id, child: child),
    );
  }
}
