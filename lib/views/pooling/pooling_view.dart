import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';

class PoolingView extends StatelessWidget {
  const PoolingView({super.key, required this.cloudUser});

  final CloudUser cloudUser;
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Caja WIP'));
  }
}
