import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:vecinapp/services/cloud/firebase_cloud_storage.dart';
import 'package:vecinapp/constants/routes.dart';
import 'dart:developer' as devtools show log;

import 'package:vecinapp/views/rulebooks/rulebook_list_view.dart';

class RulebooksView extends StatefulWidget {
  const RulebooksView({super.key});

  @override
  State<RulebooksView> createState() => _RulebooksViewState();
}

class _RulebooksViewState extends State<RulebooksView> {
  late final FirebaseCloudProvider _dbService;
  String get userId => AuthService.firebase().currentUser!.uid!;

  @override
  void initState() {
    _dbService = FirebaseCloudProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('RulebooksView');
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(
                  const AppEventGoToHomeView(),
                );
          },
        ),
        title: const Text('Reglamentos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(newRulebookRouteName);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _dbService.allRulebooks(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<Rulebook>;
                return RulebookListView(
                  rulebooks: allNotes,
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
