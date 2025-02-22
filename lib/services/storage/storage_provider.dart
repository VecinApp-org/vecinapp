import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

@immutable
abstract class StorageProvider {
  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  });

  Future<void> initialize();

  Future<Uint8List?> getProfileImage({required String userId});

  Future<void> deleteProfileImage({required String userId});
}
