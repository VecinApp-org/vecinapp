import 'package:flutter/material.dart';

List<String> pages = [
  //'Anuncios',
  //'Eventos',
  //'Contactos',
  'Reglamentos',
  //'Reservas',
  //'Mercado',
  //'Proyectos',
];

List<Icon> icons = [
  //const Icon(Icons.campaign_outlined),
  //const Icon(Icons.event),
  //const Icon(Icons.people_alt_outlined),
  const Icon(Icons.library_books_outlined),
  // const Icon(Icons.outdoor_grill_outlined),
  //const Icon(Icons.storefront),
  //const Icon(Icons.handyman_outlined),
];

List<Function()> onTap = [
  //() {},
  //() {},
  //() {},
  () {},
  //() {},
  //() {},
  //() {},
];

Widget cardBuilder(
  String title,
  Icon icon,
  Function()? onTap,
  BuildContext context,
) {
  //debugPaintSizeEnabled = true;
  return Card(
    elevation: 2,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: icon,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    ),
  );
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  final double spacing = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Las Brisas'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
          childAspectRatio: 1.61 / 1,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return cardBuilder(
            pages[index],
            icons[index],
            onTap[index],
            context,
          );
        },
      ),
    );
  }
}
