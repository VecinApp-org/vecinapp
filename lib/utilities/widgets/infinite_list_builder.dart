import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InfiniteListBuilder extends HookWidget {
  const InfiniteListBuilder({
    super.key,
    required this.fetchmore,
    required this.onRefresh,
    required this.itemBuilder,
    required this.itemCount,
    this.threshold = 300,
  });
  final Widget? Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final Function fetchmore;
  final Function onRefresh;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    useEffect(() {
      void onScroll() {
        if (!controller.hasClients) return;
        final maxScroll = controller.position.maxScrollExtent;
        final currentScroll = controller.position.pixels;
        if (maxScroll - currentScroll <= threshold) {
          fetchmore();
        }
      }

      controller.addListener(onScroll);
      return () => controller.removeListener(onScroll);
    }, [controller]);

    return RefreshIndicator(
      onRefresh: () async {
        await onRefresh();
      },
      child: ListView.builder(
        shrinkWrap: true,
        controller: controller,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
