import 'package:flutter/material.dart';

import 'contact.dart';

/// Displays detailed information about a SampleItem.
class ContactDetailsView extends StatelessWidget {
  const ContactDetailsView({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.title),
      ),
      body: Column(
        children: [
          Text(contact.description),
        ],
      ),
    );
  }
}
