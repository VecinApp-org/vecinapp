import 'package:flutter/material.dart';

@immutable
class NeighborhoodTool {
  final String title;
  final Icon icon;
  final Function() function;
  const NeighborhoodTool({
    required this.title,
    required this.icon,
    required this.function,
  });
}
