import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';

class DocView extends StatelessWidget {
  const DocView({
    super.key,
    this.appBarTitle,
    required this.title,
    required this.text,
    this.appBarActions,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle ?? ''),
        actions: appBarActions,
      ),
      body: SingleChildScrollView(
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (titlee.isNotEmpty)
                ListTile(
                  title: Text(
                    titlee,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  visualDensity:
                      VisualDensity(vertical: VisualDensity.minimumDensity),
                ),
              if (textt.isNotEmpty)
                ListTile(
                  title: Text(
                    textt,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  visualDensity:
                      VisualDensity(vertical: VisualDensity.minimumDensity),
                ),
              if (child != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: child!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
