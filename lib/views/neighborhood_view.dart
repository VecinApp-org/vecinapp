import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';
import 'package:vecinapp/utilities/entities/neighborhood_tool.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.tool,
  });
  final NeighborhoodTool tool;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 5,
      child: InkWell(
        onTap: tool.function,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                tool.icon,
                const SizedBox(width: 8),
                Text(tool.title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NeighborhoodView extends HookWidget {
  const NeighborhoodView({super.key});

  final double spacing = 16;

  @override
  Widget build(BuildContext context) {
    final tools = useMemoized(() {
      return [
        NeighborhoodTool(
          title: 'Reglamentos',
          icon: Icon(Icons.library_books_outlined),
          function: () =>
              context.read<AppBloc>().add(const AppEventGoToRulebooksView()),
        ),
      ];
    });

    final cloudUser = context.read<AppBloc>().state.cloudUser!;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 3,
          title: const Text('Las Brisas'),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 13.0),
                child: GestureDetector(
                    onTap: () => context
                        .read<AppBloc>()
                        .add(const AppEventGoToProfileView()),
                    child: ProfilePicture(
                      radius: 16,
                      id: cloudUser.id,
                    )))
          ]),
      body: GridView.builder(
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
          childAspectRatio: 2.5 / 1,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          return ToolCard(
            tool: tools[index],
          );
        },
      ),
    );
  }
}
