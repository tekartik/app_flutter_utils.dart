import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_app_rx_utils/src/behavior_subject_builder.dart';
import 'package:tekartik_app_rx_utils/src/value_stream_builder.dart';

void main() {
  test('subject builder', () async {
    var subject = BehaviorSubject<bool>();
    BehaviorSubjectBuilder(
      subject: subject,
    );

    await subject.close();
  });

  test('value_stream builder', () async {
    var subject = BehaviorSubject<bool>();
    ValueStream<bool> valueStream = subject;
    ValueStreamBuilder(
      stream: valueStream,
    );

    await subject.close();
  });
}
