import 'package:flutter/material.dart';
import 'contact.dart';
import 'contact_details_view.dart';

/// Displays a list of SampleItems.
class ContactList extends StatelessWidget {
  const ContactList({
    super.key,
    this.contacts = const [
      Contact(1, 'Contacto 1', 'Descripción 1'),
      Contact(2, 'Contacto 2', 'Descripción 2'),
      Contact(3, 'Contacto 3', 'Descripción 3')
    ],
  });
  final List<Contact> contacts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      restorationId: 'contactList',
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Column(
          children: [
            ListTile(
                title: Text(contact.title),
                leading: const Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContactDetailsView(contact: contact),
                    ),
                  );
                }),
            const Divider(),
          ],
        );
      },
    );
  }
}
