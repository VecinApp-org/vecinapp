import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';

class DocView extends StatelessWidget {
  const DocView({
    super.key,
    this.appBarTitle,
    required this.title,
    required this.text,
    required this.appBarActions,
    this.child,
  });
  final String? appBarTitle;
  final String? title;
  final String? text;
  final List<Widget>? appBarActions;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final titlee = title ?? '';
    final textt = text ?? '';
    final children = child ?? Container();
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle ?? ''),
        actions: appBarActions,
      ),
      body: SingleChildScrollView(
        child: CustomCard(
          child: ListTile(
            //contentPadding:
            //  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: (titlee.isNotEmpty)
                ? Text(
                    titlee,
                    style: Theme.of(context).textTheme.headlineSmall,
                  )
                : null,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                if (textt.isNotEmpty)
                  Text(
                    textt,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
