// The web js bridge: flutter test --platform chrome (and --wasm).
@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_agent_flutter/app_agent_flutter.dart';
import 'package:tekartik_app_agent_flutter/src/agent_bridge_web.dart';

/// What `window.tekartikAgent.run(name, <args expression>)` resolves to.
Future<Map> _run(String name, String argsExpression) async {
  var bridge = globalContext[agentBridgeName] as JSObject;
  var args = globalContext.callMethod<JSAny?>(
    'eval'.toJS,
    '($argsExpression)'.toJS,
  );
  var promise = bridge.callMethod<JSPromise<JSAny?>>(
    'run'.toJS,
    name.toJS,
    args,
  );
  return (await promise.toDart).dartify() as Map;
}

void main() {
  test('run: the args have the types of the VM extension', () async {
    var commands = AgentCommands();
    commands.add([
      AgentCommand(
        name: 'types',
        description: 'The Dart types of the args.',
        run: (args) => {
          'count': args['count'] is int,
          'ratio': args['ratio'] is double,
          'filter': args['filter'] is Map<String, Object?>,
          'tags': args['tags'] is List,
        },
      ),
    ]);
    agentBridgeInstall(commands);
    var expected = {
      'ok': true,
      'result': {'count': true, 'ratio': true, 'filter': true, 'tags': true},
    };
    // An object (what the MCP server sends), or its json.
    expect(
      await _run(
        'types',
        '{"count": 3, "ratio": 0.5, "filter": {"a": 1}, "tags": ["x"]}',
      ),
      expected,
    );
    expect(
      await _run(
        'types',
        '\'{"count": 3, "ratio": 0.5, "filter": {"a": 1}, "tags": ["x"]}\'',
      ),
      expected,
    );
  });
}
