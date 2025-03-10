import 'package:flutter/material.dart';

import 'cv_ui_impl.dart';
import 'cv_ui_model_controller.dart';

class CvUiListChildrenPrv extends StatefulWidget {
  final List<Widget> children;

  const CvUiListChildrenPrv({super.key, required this.children});

  @override
  State<CvUiListChildrenPrv> createState() => _CvUiListChildrenPrvState();
}

class _CvUiListChildrenPrvState extends State<CvUiListChildrenPrv> {
  @override
  Widget build(BuildContext context) {
    var controller = CvUiModelViewProviderImpl.of(context);
    var editController =
        controller is CvUiModelEditControllerImpl ? controller : null;
    return cvUiColumnPrv(children: [
      ...widget.children.indexed.map((entry) {
        return CvUiListItemWithChild(
            index: entry.$1, indented: true, child: entry.$2);

        /*
        //return CvUiFieldWithChild(name: name)
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            const Text('-'),
            child,
          ],
        );*/
      }),
      if (editController != null)
        IconButton(
          iconSize: 16,
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.add,
          ),
          onPressed: () async {
            var result = await editController.add(context, widget);
            if (result) {
              setState(() {});
            }
          },
        ),
    ]);
  }
}

class CvUiMapChildrenPrv extends StatelessWidget {
  final Map<String, Widget> children;
  final bool? indented;

  const CvUiMapChildrenPrv(
      {super.key, required this.children, required this.indented});

  @override
  Widget build(BuildContext context) {
    return cvUiColumnPrv(
      children: children
          .map((key, value) {
            return MapEntry(
                key,
                CvUiFieldWithChild(
                  name: key,
                  indented: indented,
                  child: value,
                ));
          })
          .values
          .toList(),
    );
  }
}

/// Column with children
Widget cvUiColumnPrv({required List<Widget> children}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: children,
  );
}
