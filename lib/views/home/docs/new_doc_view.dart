import 'package:flutter/material.dart';

class NewDocView extends StatefulWidget {
  const NewDocView({super.key});

  @override
  State<NewDocView> createState() => _NewDocViewState();
}

class _NewDocViewState extends State<NewDocView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Doc'),
      ),
      body: const Text('New Doc'),
    );
  }
}
