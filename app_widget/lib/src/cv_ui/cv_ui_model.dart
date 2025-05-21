import 'package:cv/cv.dart';
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';

import 'cv_ui_model_controller.dart';
import 'cv_ui_value_ref.dart';

class CvUiModelView extends StatefulWidget {
  final CvUiModelViewController? controller;
  final CvModel model;

  const CvUiModelView({super.key, required this.model, this.controller});

  @override
  State<CvUiModelView> createState() => _CvUiModelViewState();
}

class _CvUiModelViewState extends State<CvUiModelView> {
  late final CvUiModelViewControllerImpl controller =
      (widget.controller as CvUiModelViewControllerImpl?) ??
      CvUiModelViewControllerImpl();

  @override
  Widget build(BuildContext context) {
    var model = widget.model;
    return CvUiModelViewProviderPrv(
      controller: controller,
      child: CvUiModelValue(model: model),
    );
  }
}

class CvUiModelEdit extends StatefulWidget {
  final CvUiModelEditController controller;

  const CvUiModelEdit({super.key, required this.controller});

  @override
  State<CvUiModelEdit> createState() => _CvUiEditState();
}

class _CvUiEditState extends State<CvUiModelEdit> {
  late final CvUiModelEditControllerImpl controller =
      (widget.controller as CvUiModelEditControllerImpl?) ??
      CvUiModelEditControllerImpl(model: CvMapModel());
  @override
  void initState() {
    controller.triggerRedraw = () {
      setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var model = controller.model;
    return CvUiModelViewProviderPrv(
      controller: controller,
      child: CvUiModelValue(model: model),
    );
  }
}

class CvUiModelValueEdit extends StatelessWidget {
  final CvModel model;
  final CvUiValueRef ref;

  const CvUiModelValueEdit({super.key, required this.model, required this.ref});

  @override
  Widget build(BuildContext context) {
    return CvUiModelValue(model: model);
  }
}
