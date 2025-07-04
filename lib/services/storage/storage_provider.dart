import 'dart:io';

import 'package:flutter/material.dart';

@immutable
abstract class StorageProvider {
  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  });

  Future<void> initialize();

  Future<void> deleteProfileImage({required String userId});
}
