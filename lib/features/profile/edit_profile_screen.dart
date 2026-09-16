import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/core/config/api_config.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _artistController;
  late final TextEditingController _disciplineController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;

  File? _avatarFile;
  File? _bannerFile;
  bool _isPrivate = false;
  bool _saving = false;

  String? _remoteAvatarUrl;
  String? _remoteBannerUrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    final p = auth.backendProfile;
    final user = auth.currentUser;

    _nameController = TextEditingController(
      text: p?.name ?? user?.fullName ?? user?.displayName ?? '',
    );
    _artistController = TextEditingController(
      text: p?.artisticName ?? user?.artistName ?? '',
    );
    _disciplineController = TextEditingController(
      text: p?.discipline ?? user?.discipline ?? '',
    );
    _locationController = TextEditingController(text: p?.location ?? '');
    _bioController = TextEditingController(text: p?.bio ?? user?.bio ?? '');
    _isPrivate = p?.isPrivate ?? false;

    _remoteAvatarUrl = p?.avatarUrlAbsolute;
    _remoteBannerUrl = p?.bannerUrlAbsolute;
    if (user?.photoPath != null && user!.photoPath!.isNotEmpty) {
      _avatarFile = File(user.photoPath!);
    }
    if (user?.coverPhotoPath != null && user!.coverPhotoPath!.isNotEmpty) {
      _bannerFile = File(user.coverPhotoPath!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _artistController.dispose();
    _disciplineController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool avatar}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() {
      if (avatar) {
        _avatarFile = File(image.path);
      } else {
        _bannerFile = File(image.path);
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final auth = context.read<AuthController>();

    // Sólo se sube un archivo si el usuario eligió uno nuevo en esta pantalla.
    final failure = await auth.updateProfile(
      name: _nameController.text.trim(),
      artistName: _artistController.text.trim(),
      discipline: _disciplineController.text.trim(),
      location: _locationController.text.trim(),
      bio: _bioController.text.trim(),
      isPrivate: _isPrivate,
      avatarPath: _avatarPicked ? _avatarFile?.path : null,
      bannerPath: _bannerPicked ? _bannerFile?.path : null,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (failure != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              failure.fieldErrors.isNotEmpty
                  ? failure.fieldErrors.values.first
                  : failure.message,
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    Navigator.pop(context);
  }

  // Marca si el usuario tocó el selector en esta sesión de edición.
  bool _avatarPicked = false;
  bool _bannerPicked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;

    final ImageProvider? avatarImg = _avatarFile != null
        ? FileImage(_avatarFile!)
        : (_remoteAvatarUrl != null
              ? NetworkImage(ApiConfig.resolveMediaUrl(_remoteAvatarUrl))
              : null);
    final ImageProvider? bannerImg = _bannerFile != null
        ? FileImage(_bannerFile!)
        : (_remoteBannerUrl != null
              ? NetworkImage(ApiConfig.resolveMediaUrl(_remoteBannerUrl))
              : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner
          GestureDetector(
            onTap: () {
              _bannerPicked = true;
              _pick(avatar: false);
            },
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white10,
                image: bannerImg != null
                    ? DecorationImage(image: bannerImg, fit: BoxFit.cover)
                    : null,
              ),
              alignment: Alignment.center,
              child: bannerImg == null
                  ? const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.white54,
                      size: 34,
                    )
                  : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: GestureDetector(
              onTap: () {
                _avatarPicked = true;
                _pick(avatar: true);
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white10,
                    backgroundImage: avatarImg,
                    child: avatarImg == null
                        ? const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white54,
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          _label(l10n.editProfileNameLabel),
          _field(_nameController),
          const SizedBox(height: 18),

          _label('Nombre artístico'),
          _field(_artistController),
          const SizedBox(height: 18),

          _label('Disciplina'),
          _field(_disciplineController),
          const SizedBox(height: 18),

          _label('Ubicación'),
          _field(_locationController),
          const SizedBox(height: 18),

          _label(l10n.editProfileBioLabel),
          _field(_bioController, maxLines: 4),
          const SizedBox(height: 12),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _isPrivate,
            onChanged: (v) => setState(() => _isPrivate = v),
            title: const Text('Cuenta privada'),
            subtitle: const Text(
              'Sólo tus seguidores verán tu contenido',
              style: TextStyle(fontSize: 12),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.commonSave,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 13),
    ),
  );

  Widget _field(TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
