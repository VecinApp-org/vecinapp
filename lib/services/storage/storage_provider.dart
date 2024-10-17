import 'dart:io';

import 'package:flutter/material.dart';

@immutable
abstract class StorageProvider {
  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  });
}
