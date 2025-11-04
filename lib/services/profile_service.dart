import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class ProfileService {
  ProfileService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Profile?> fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromMap(Map<String, dynamic>.from(data));
  }

  Future<Profile> upsertProfile(Profile profile) async {
    final payload = profile.toMap()
      ..['updated_at'] = DateTime.now().toIso8601String();

    final data = await _client
        .from('profiles')
        .upsert(payload, onConflict: 'id')
        .select()
        .single();

    return Profile.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> ensureProfileRow(String userId) async {
    await _client
        .from('profiles')
        .upsert({'id': userId}, onConflict: 'id');
  }

  Future<String> uploadAvatar(
    String userId, {
    required List<int> bytes,
    String? filePath,
    String? mimeType,
  }) async {
    final inferredMime = mimeType ??
        (filePath != null ? lookupMimeType(filePath) : null) ??
        'application/octet-stream';
    final extFromPath = filePath != null && filePath.contains('.')
        ? filePath.substring(filePath.lastIndexOf('.') + 1)
        : '';
    final ext = extFromPath.isNotEmpty
        ? extFromPath
        : _extensionFromMime(inferredMime) ?? 'jpg';
    final fileName = '$userId/avatar.$ext';

    await _client.storage.from('profile_images').uploadBinary(
          fileName,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(
            upsert: true,
            contentType: inferredMime,
          ),
        );

    return _client.storage.from('profile_images').getPublicUrl(fileName);
  }

  String? _extensionFromMime(String mime) {
    switch (mime) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      default:
        return null;
    }
  }
}
