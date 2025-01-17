import 'package:flutter/material.dart';

class DocView extends StatelessWidget {
  const DocView({
    super.key,
    this.appBarTitle,
    required this.title,
    required this.text,
    required this.appBarBackAction,
    required this.appBarActions,
    required this.more,
  });
  final String? appBarTitle;
  final String? title;
  final String? text;
  final VoidCallback? appBarBackAction;
  final List<Widget>? appBarActions;
  final List<Widget>? more;

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
      body: Card(
        color: Theme.of(context).colorScheme.surfaceContainer,
        margin: const EdgeInsets.all(8),
        child: ListView(
          padding: const EdgeInsets.all(13),
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            if (text != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  text ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            if (more != null) ...more!,
          ],
        ),
      ),
    );
  }
}
