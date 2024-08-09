import 'package:flutter/material.dart';
import 'contact.dart';
import 'contact_details_view.dart';
import '../home/home_drawer.dart';

/// Displays a list of SampleItems.
class ContactListView extends StatelessWidget {
  const ContactListView({
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      drawer: const HomeDrawer(),
      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'contactListView',
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
      ),
    );
  }
}
