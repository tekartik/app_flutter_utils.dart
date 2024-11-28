import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_image_flutter/src/app_image_utils.dart';
import 'package:tekartik_app_image_flutter/src/app_image_widget.dart';

void main() {
  testWidgets('MyWidget has a title and message', (tester) async {
    var image = await image1x1WhiteAsync;
    await tester.pumpWidget(UiImage(
      image: image,
    ));
    var finder = find.text('0');
    expect(finder, findsNothing);
  });
}
