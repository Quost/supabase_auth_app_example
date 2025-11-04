import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _cpfCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _picker = ImagePicker();

  final _service = ProfileService();

  Profile? _profile;
  bool _loadingProfile = true;
  bool _saving = false;
  Uint8List? _previewBytes;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _cpfCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).maybePop();
      return;
    }
    setState(() => _loadingProfile = true);

    try {
      final profile =
          await _service.fetchProfile(user.id) ?? Profile(id: user.id);
      _profile = profile;
      _cpfCtrl.text = profile.cpf ?? '';
      _phoneCtrl.text = profile.phone ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao carregar perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (mounted) {
        setState(() {
          _pickedImage = picked;
          _previewBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao carregar imagem: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      String? profileImageUrl = _profile?.profileImageUrl;
      if (_pickedImage != null && _previewBytes != null) {
        final sourceName =
            _pickedImage!.path.isNotEmpty ? _pickedImage!.path : _pickedImage!.name;
        final mime =
            lookupMimeType(sourceName, headerBytes: _previewBytes!) ?? 'image/jpeg';
        profileImageUrl = await _service.uploadAvatar(
          user.id,
          bytes: _previewBytes!,
          filePath: sourceName,
          mimeType: mime,
        );
      }

      final sanitizedCpf = _cleanDigits(_cpfCtrl.text);
      final sanitizedPhone = _cleanDigits(_phoneCtrl.text);

      final updated = Profile(
        id: user.id,
        cpf: sanitizedCpf.isEmpty ? null : sanitizedCpf,
        phone: sanitizedPhone.isEmpty ? null : sanitizedPhone,
        profileImageUrl: profileImageUrl,
      );

      final saved = await _service.upsertProfile(updated);
      if (mounted) {
        setState(() {
          _profile = saved;
          _pickedImage = null;
          _previewBytes = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.of(context).pop(saved);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _cleanDigits(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String? _validateCpf(String? value) {
    if (value == null || value.isEmpty) return null;
    final digits = _cleanDigits(value);
    if (digits.length != 11) {
      return 'CPF deve conter 11 dígitos';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    final digits = _cleanDigits(value);
    if (digits.length < 10 || digits.length > 11) {
      return 'Informe um telefone válido (10 ou 11 dígitos)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundImage: _previewBytes != null
                                  ? MemoryImage(_previewBytes!)
                                  : (_profile?.profileImageUrl != null
                                      ? NetworkImage(_profile!.profileImageUrl!)
                                      : null),
                              child: _previewBytes == null &&
                                      _profile?.profileImageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 48,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: IconButton.filledTonal(
                                onPressed: _pickAvatar,
                                icon: const Icon(Icons.edit),
                                tooltip: 'Alterar foto',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (user?.email != null)
                        Text(
                          user!.email!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _cpfCtrl,
                        decoration: const InputDecoration(
                          labelText: 'CPF',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateCpf,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Salvar alterações'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
