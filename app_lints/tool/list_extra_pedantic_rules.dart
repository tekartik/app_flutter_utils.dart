import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

/// Read info from `.packages` file, key being the package, value being the path
Future<Map<String, String>> getDotPackagesMap(String packageRoot) async {
  final yamlPath = join(packageRoot, '.packages');
  final content = await File(yamlPath).readAsString();

  final map = <String, String>{};
  final lines = LineSplitter.split(content);
  for (var line in lines) {
    line = line.trim();
    if (!line.startsWith('#')) {
      final separator = line.indexOf(':');
      if (separator != -1) {
        map[line.substring(0, separator)] = line.substring(separator + 1);
      }
    }
  }
  return map;
}

Future<List<String>> getRules(String path) async {
  var yaml = loadYaml(await File(path).readAsString()) as Map;
  var rawRules = (yaml['linter'] as Map)['rules'];
  List<String> rules;
  if (rawRules is List) {
    rules = List<String>.from(rawRules.cast<String>())..sort();
    return rules;
  }
  throw UnsupportedError('invalid rawRules type ${rawRules.runtimeType}');
}

Future<void> _writeRules(String name, List<String> rules) async {
  var sb = StringBuffer();
  for (var rule in rules) {
    sb.writeln('  - $rule');
  }
  await Directory('.local').create(recursive: true);
  await File(join('.local', '${name}_rules.txt')).writeAsString(sb.toString());
}

Future<void> main() async {
  var dotPackagesMap = await getDotPackagesMap('.');

  var tekartikLintsLibPath = Uri.parse(
    dotPackagesMap['tekartik_lints']!,
  ).toFilePath();
  var pedanticLibPath = Uri.parse(dotPackagesMap['pedantic']!).toFilePath();
  var flutterLintsLibPath = Uri.parse(
    dotPackagesMap['flutter_lints']!,
  ).toFilePath();
  var lintsLibPath = Uri.parse(dotPackagesMap['lints']!).toFilePath();

  var tekartikLintsRules = await getRules(
    join(tekartikLintsLibPath, 'recommended.yaml'),
  );
  await _writeRules('common_utils', tekartikLintsRules);
  var pedanticRules = await getRules(
    join(pedanticLibPath, 'analysis_options.1.11.0.yaml'),
  );
  await _writeRules('pedantic', pedanticRules);
  var flutterLintsRules = await getRules(
    join(flutterLintsLibPath, 'flutter.yaml'),
  );
  await _writeRules('flutter_lints', flutterLintsRules);
  var lintsRules = await getRules(join(lintsLibPath, 'recommended.yaml'));

  await _writeRules('lints', lintsRules);

  var diffRules = List<String>.from(tekartikLintsRules);
  diffRules.removeWhere((element) => pedanticRules.contains(element));
  await _writeRules('pedantic_diff', diffRules);
  diffRules = List<String>.from(tekartikLintsRules);
  diffRules.removeWhere((element) => flutterLintsRules.contains(element));
  await _writeRules('lints_diff', diffRules);
  diffRules = List<String>.from(flutterLintsRules);
  diffRules.removeWhere((element) => pedanticRules.contains(element));
  await _writeRules('lints_over_pedantic', diffRules);
  diffRules = List<String>.from(pedanticRules);
  diffRules.removeWhere((element) => flutterLintsRules.contains(element));
  await _writeRules('pedantic_over_lints', diffRules);

  var all = <String>{}
    ..addAll(tekartikLintsRules)
    ..addAll(pedanticRules)
    ..addAll(flutterLintsRules)
    ..addAll(lintsRules);
  diffRules = List<String>.from(all)..sort();
  diffRules.removeWhere((element) => flutterLintsRules.contains(element));
  diffRules.removeWhere((element) => lintsRules.contains(element));
  await _writeRules('tekartik_recommended_over_flutter_lints', diffRules);
}
