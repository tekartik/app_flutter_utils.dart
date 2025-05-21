import 'package:flutter/material.dart';

/// ListView with header and footer
class WithHeaderFooterListView extends StatelessWidget {
  final NullableIndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final Widget? header;
  final Widget? footer;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool shrinkWrap;
  const WithHeaderFooterListView.separated({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.padding,
    this.header,
    this.footer,
    required this.separatorBuilder,
    this.shrinkWrap = false,
  });

  const WithHeaderFooterListView.builder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.padding,
    this.header,
    // Should be null
    this.separatorBuilder,
    this.footer,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? wrappedItemBuilder(BuildContext context, int index) {
      if (header != null) {
        if (index == 0) {
          return header!;
        }
        index--;
      }
      if (footer != null) {
        if (index == itemCount) {
          return footer!;
        }
      }
      return itemBuilder(context, index);
    }

    var wrappedItemCount =
        itemCount + (header != null ? 1 : 0) + (footer != null ? 1 : 0);
    if (separatorBuilder != null) {
      return ListView.separated(
        shrinkWrap: shrinkWrap,
        padding: padding,
        itemBuilder: wrappedItemBuilder,
        separatorBuilder: separatorBuilder!,
        itemCount: wrappedItemCount,
      );
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemBuilder: wrappedItemBuilder,
      itemCount: wrappedItemCount,
    );
  }
}
