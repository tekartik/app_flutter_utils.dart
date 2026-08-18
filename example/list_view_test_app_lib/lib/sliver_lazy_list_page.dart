import 'package:flutter/material.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';
import 'package:tekartik_list_view_test_app_lib/demo_store.dart';

/// Demo page for [SliverLazyList] mixed with other slivers in a
/// [CustomScrollView].
class SliverLazyListDemoPage extends StatefulWidget {
  /// Constructor
  const SliverLazyListDemoPage({super.key});

  @override
  State<SliverLazyListDemoPage> createState() => _SliverLazyListDemoPageState();
}

class _SliverLazyListDemoPageState extends State<SliverLazyListDemoPage> {
  final _store = DemoStore(count: 10000);
  late final LazyListController<String> _controller =
      LazyListController<String>.future(
        getItems: _store.getItems,
        getCount: _store.getCount,
        pageSize: 30,
      );

  @override
  void dispose() {
    _controller.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(title: Text('SliverLazyList')),
          ),
          const SliverToBoxAdapter(
            child: ListTile(
              title: Text('A header sliver'),
              subtitle: Text('Followed by a lazily loaded sliver list'),
            ),
          ),
          SliverLazyList<String>(
            controller: _controller,
            itemExtent: 56,
            itemLoadingBuilder: (context, index) =>
                ListTile(dense: true, title: Text('loading ${index + 1}...')),
            itemBuilder: (context, item, index) => ListTile(
              dense: true,
              leading: Text('${index + 1}'),
              title: Text(item),
            ),
          ),
          const SliverToBoxAdapter(
            child: ListTile(title: Text('A footer sliver')),
          ),
        ],
      ),
    );
  }
}
