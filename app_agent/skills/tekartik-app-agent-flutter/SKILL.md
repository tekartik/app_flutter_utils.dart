---
name: tekartik-app-agent-flutter
description: >-
  Use when giving a Flutter app stable automation ids so that an agent (an
  LLM with a browser, adb/uiautomator, Playwright, a headless Chrome check)
  can drive it, with tekartik_app_agent_flutter: AgentId (Semantics
  identifier merged with the control, container), agentInit (?semantics,
  ?agent build the semantics from the start on the web; the commands exposed
  by the window.tekartikAgent js bridge with ?agent and by the VM service
  extensions ext.tekartik.agent.* in debug), AgentCommandsScope,
  agentUrlOptions; and when testing those ids in widget tests.
---

# Agent ids for Flutter apps (tekartik_app_agent_flutter)

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_agent_flutter:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_agent
  ```
* `AgentId(id, child:)` wraps a control in
  `MergeSemantics(Semantics(identifier: id))`: the node the platform exposes
  (the merge boundary) carries the id, the label and the tap together. The id
  becomes the Android `resource-id`, the iOS `accessibilityIdentifier` and the
  web `flt-semantics-identifier`.
* `AgentId(id, container: true, child:)` for a group (a row of buttons, a
  list) and for a tappable row or card holding other controls (an `InkWell`
  row with a favorite `IconButton`): its own node with the id, which also
  gets the `InkWell` tap and the texts, while the inner controls stay nodes
  of their own. Do not nest a plain `AgentId` around other controls with a
  tap: the merge would swallow them.
* Inside a widget that already builds the node of a control (a
  `NavigationDestination` icon, a `Tab`, a `NavigationRailDestination`
  label), use a plain `Semantics(identifier: id, child: ...)`: in a bar or a
  tab it merges into the control's node; in a rail it is a child of the tab
  node, and a web click on it bubbles to the tab (checked in headless
  Chrome).
* A page in a nested navigator (go_router `ShellRoute`) next to a sidebar
  painted before it: the route barrier's `BlockSemantics` drops the
  semantics of the sidebar (no ids, no screen reader). Wrap the navigator
  side in `Semantics(container: true, child: ...)`.
* Commands (`AgentCommand` of tekartik_app_agent, re-exported): register
  them where their context lives, with `AgentCommandsScope(commands:,
  child:)` (built once, e.g. a `late final` list in the state of the app
  root holding the router and the database), or `agentCommands.add(...)`.
  `agentInit()` exposes whatever is registered when called: the js bridge
  `window.tekartikAgent` with `?agent` (release builds included: the agent
  acts as the signed-in user, no extra rights), the VM service extensions
  `ext.tekartik.agent.commands` / `ext.tekartik.agent.run` (params `name`,
  `args` json) in debug and profile.
* From a browser agent: `await window.tekartikAgent.run('events', {day:
  '2027-01-15'})` gives `{ok: true, result}` or `{ok: false, error}`;
  `window.tekartikAgent.commands()` the names, descriptions and argument
  schemas. From a tool: `AgentWebPage.run` (tekartik_app_agent).
* Ids are an api: one constants class per app (`abstract final class
  MyUiIds { static const home = 'home'; static String event(String id) =>
  'event-$id'; }`) in a pure Dart library, imported by the app and the
  tools. Ids do not depend on the locale or the wording.
* Give every `IconButton` a `tooltip:` (its label for agents and screen
  readers).
* `agentInit()` after `WidgetsFlutterBinding.ensureInitialized()`: with
  `?semantics` or `?agent` in the url (query, or the fragment query of a hash
  url: `/#/home?agent`) it keeps `SemanticsBinding.instance.ensureSemantics()`
  for the life of the app. `agentUrlOptions` gives the options read.
* Widget tests: the node to look for is the one not merged into its parent,
  whose merged data has the id:
  ```dart
  SemanticsFinder byAgentId(String id) => find.semantics.byPredicate(
    (node) =>
        !node.isMergedIntoParent && node.getSemanticsData().identifier == id,
  );
  // tester.semantics.tap(byAgentId('play'));
  ```
  `tester.getSemantics(find.text('Play')).getSemanticsData().identifier` is
  the id too. A node found by `node.identifier == id` alone may be the merged
  up child, without the tap.
* A web check drives the ids with `AgentWebPage` (tekartik_app_agent) in
  headless Chrome, the app opened with `?semantics`.

## Example

```dart
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_agent_flutter/app_agent_flutter.dart';

abstract final class DemoUiIds {
  static const play = 'play';
  static const toolbar = 'toolbar';
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  agentInit();
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            AgentId(
              'settings',
              child: IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: AgentId(
          DemoUiIds.play,
          child: FilledButton(onPressed: () {}, child: const Text('Play')),
        ),
      ),
    ),
  );
}
```
