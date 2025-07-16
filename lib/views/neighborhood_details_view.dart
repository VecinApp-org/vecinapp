import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';

class NeighborhoodDetailsView extends StatelessWidget {
  const NeighborhoodDetailsView({super.key, required this.neighborhood});

  final Neighborhood neighborhood;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(neighborhood.neighborhoodName),
      ),
      body: ListView(
          children: neighborhood.polygon
              .map((e) => Text('${e.x.toString()}, ${e.y.toString()}'))
              .toList()),
    );
  }
}
