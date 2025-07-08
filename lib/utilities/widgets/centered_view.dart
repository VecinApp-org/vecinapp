import 'package:flutter/material.dart';

class CenteredView extends StatelessWidget {
  const CenteredView({super.key, required this.children, this.appbar});

  final List<Widget> children;

  final AppBar? appbar;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appbar,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: children,
              ),
            ),
          ),
        ),
      );
}
