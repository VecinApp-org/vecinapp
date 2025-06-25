import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class ForumView extends HookWidget {
  const ForumView(
      {super.key, required this.cloudUser, required this.neighborhood});
  final CloudUser cloudUser;
  final Neighborhood neighborhood;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Foro',
        ),
      ),
      body: Center(
        child: Text(
          'Foro WIP',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
