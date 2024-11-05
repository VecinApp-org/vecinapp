import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/views/cloud_login/select_address_view.dart';

class ChangeAddressView extends StatelessWidget {
  const ChangeAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.read<AppBloc>().add(const AppEventGoToProfileView()),
        ),
      ),
      body: const SelectAddressView(),
    );
  }
}
