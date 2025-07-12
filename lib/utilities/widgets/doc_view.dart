import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';

class DocView extends StatelessWidget {
  const DocView({
    super.key,
    this.appBarTitle,
    required this.title,
    required this.text,
    required this.appBarBackAction,
    required this.appBarActions,
    required this.children,
  });
  final String? appBarTitle;
  final String? title;
  final String? text;
  final VoidCallback? appBarBackAction;
  final List<Widget>? appBarActions;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle ?? ''),
        leading: BackButton(
          onPressed: appBarBackAction,
        ),
        actions: appBarActions,
      ),
      body: SingleChildScrollView(
        child: CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                if (text != null)
                  Text(
                    text ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (children != null) ...children!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
