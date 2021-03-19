import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

import 'package:tekartik_app_rx_utils/app_rx_utils.dart';

void main() {
  test('subject builder', () async {
    var subject = BehaviorSubject<bool>();
    BehaviorSubjectBuilder(
      subject: subject,
      builder: (_, __) => Container(),
    );

    await subject.close();
  });

  test('value_stream builder', () async {
    var subject = BehaviorSubject<bool>();
    ValueStream<bool> valueStream = subject;
    ValueStreamBuilder(
      stream: valueStream,
      builder: (_, __) => Container(),
    );

    await subject.close();
  });
}
