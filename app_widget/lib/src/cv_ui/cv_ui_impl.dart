import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';

import 'cv_ui_layout.dart';
import 'cv_ui_model_controller.dart';

var debugCvUi = false;

class CvUiFieldWithChild extends StatelessWidget {
  final String name;
  final Widget? child;
  final bool? indented;

  const CvUiFieldWithChild({
    required this.name,
    this.child,
    this.indented,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CvUiWidgetWithChild(
      widget: CvUiFieldLabel(name: name),
      indented: indented,
      child: child,
    );
  }
}

class CvUiListItemWithChild extends StatelessWidget {
  final int index;
  final Widget? child;
  final bool? indented;

  const CvUiListItemWithChild({
    required this.index,
    this.child,
    this.indented,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CvUiWidgetWithChild(
      widget: CvUiListItemLabel(index: index),
      indented: indented,
      child: child,
    );
  }
}

class CvUiWidgetWithChild extends StatefulWidget {
  final Widget widget;
  final Widget? child;
  final bool? indented;

  const CvUiWidgetWithChild({
    required this.widget,
    this.child,
    this.indented,
    super.key,
  });

  @override
  State<CvUiWidgetWithChild> createState() => _CvUiWidgetWithChildState();
}

class _CvUiWidgetWithChildState extends State<CvUiWidgetWithChild> {
  void _edit() async {
    var controller = CvUiModelEditProviderImpl.of(context);
    var result = await controller?.edit(context, widget);
    if (result == true) {
      setState(() {});
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    var controller = CvUiModelViewProviderImpl.of(context);
    var editController = controller is CvUiModelEditControllerImpl
        ? controller
        : null;
    var indented = widget.indented ?? false;
    var childWidget = indented
        ? Padding(padding: const EdgeInsets.only(left: 16), child: widget.child)
        : widget.child;

    var mainWidget = widget.widget;
    var expanded = true;
    if (controller != null && indented) {
      expanded = controller.isWidgetExpanded(widget);
      mainWidget = InkWell(
        onTap: () {
          setState(() {
            // ignore: unused_local_variable
            var result = controller.toggleWidget(widget);
            //print('selectField $this $result');
          });
        },
        child: Row(
          children: [
            mainWidget,
            Icon(
              expanded ? Icons.arrow_drop_down : Icons.arrow_right,
              size: 16,
            ),
          ],
        ),
      );
    }
    var view = cvUiColumnPrv(
      children: [
        mainWidget,
        if ((childWidget != null) && expanded) childWidget,
      ],
    );
    if (editController != null && childWidget != null) {
      // && !indented) {
      view = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            iconSize: 8,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.edit),
            onPressed: () {
              _edit();
              //      editController.editField(widget);
            },
          ),
          view,
        ],
      );
    }
    return view;
  }
}
