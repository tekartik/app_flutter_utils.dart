import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_agent_flutter/app_agent_flutter.dart';

/// The semantics node of [id] the platform sees: not merged into a parent,
/// with [id] in its merged data.
SemanticsFinder _byId(String id) => find.semantics.byPredicate(
  (node) =>
      !node.isMergedIntoParent && node.getSemanticsData().identifier == id,
);

void main() {
  testWidgets('AgentId merges the id with the label and the tap', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentId(
            'play',
            child: TextButton(
              onPressed: () => tapped++,
              child: const Text('Play'),
            ),
          ),
        ),
      ),
    );
    // The node the platform sees: the merge boundary, with the merged id,
    // label and tap (the web `flt-semantics-identifier`).
    var data = tester.getSemantics(find.text('Play')).getSemanticsData();
    expect(data.identifier, 'play');
    expect(data.label, 'Play');
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    tester.semantics.tap(_byId('play'));
    expect(tapped, 1);
  });

  testWidgets('AgentId container keeps its children apart', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentId(
            'toolbar',
            container: true,
            child: Row(
              children: [
                AgentId(
                  'a',
                  child: TextButton(onPressed: () {}, child: const Text('A')),
                ),
                AgentId(
                  'b',
                  child: TextButton(onPressed: () {}, child: const Text('B')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(_byId('toolbar'), findsOne);
    expect(_byId('a'), findsOne);
    expect(_byId('b'), findsOne);
  });

  test('agentInit', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(agentInit(uri: Uri.parse('https://x.org/')).needsSemantics, isFalse);
    expect(agentUrlOptions.agent, isFalse);
    var options = agentInit(uri: Uri.parse('https://x.org/#/home?agent'));
    expect(options.agent, isTrue);
    expect(agentUrlOptions.agent, isTrue);
    expect(SemanticsBinding.instance.semanticsEnabled, isTrue);
  });

  testWidgets('AgentCommandsScope registers while in the tree', (tester) async {
    var registry = AgentCommands();
    AgentCommand command(String result) =>
        AgentCommand(name: 'hello', description: 'Hello.', run: (_) => result);
    await tester.pumpWidget(
      AgentCommandsScope(
        registry: registry,
        commands: [command('one')],
        child: const SizedBox(),
      ),
    );
    expect((await registry.run('hello')).result, 'one');
    // Rebuilt with other commands: replaced.
    await tester.pumpWidget(
      AgentCommandsScope(
        registry: registry,
        commands: [command('two')],
        child: const SizedBox(),
      ),
    );
    expect((await registry.run('hello')).result, 'two');
    expect(registry.describe(), hasLength(1));
    await tester.pumpWidget(const SizedBox());
    expect(registry.describe(), isEmpty);
  });
}
