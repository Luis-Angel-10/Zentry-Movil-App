import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/community.dart';
import 'package:Zentry/core/models/zentry_category.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/features/communities/community_detail_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hashtagsController = TextEditingController();
  final _rulesController = TextEditingController();

  File? _iconFile;
  File? _coverFile;
  CategoryGroup _selectedGroup = kZentryCategoryGroups.first;
  String? _selectedSubcategory;
  CommunityPrivacy _privacy = CommunityPrivacy.public;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hashtagsController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isCover}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;

    setState(() {
      if (isCover) {
        _coverFile = File(image.path);
      } else {
        _iconFile = File(image.path);
      }
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final user = context.read<AuthController>().currentUser;
    if (user == null) {
      setState(() => _saving = false);
      return;
    }

    final hashtags = _hashtagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final community = await context.read<CommunityController>().createCommunity(
      creator: user,
      name: _nameController.text,
      description: _descriptionController.text,
      categoryName: _selectedGroup.name,
      subcategoryName: _selectedSubcategory,
      privacy: _privacy,
      iconPath: _iconFile?.path,
      coverPath: _coverFile?.path,
      rules: _rulesController.text,
      hashtags: hashtags,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.communityCreatedSnackbar)));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(communityId: community.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.communityCreateTitle)),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildCoverAndIconPicker(accentColor),

            const SizedBox(height: 28),

            Text(
              l10n.communityCreateNameLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDecoration(l10n.communityCreateNameHint),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return l10n.communityCreateNameRequiredError;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            Text(
              l10n.communityCreateDescriptionLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDecoration(l10n.communityCreateDescriptionHint),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return l10n.communityCreateDescriptionRequiredError;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            Text(
              l10n.communityCreateCategoryLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),

            const SizedBox(height: 20),

            Text(
              l10n.communityCreateSubcategoryLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildSubcategoryDropdown(l10n),

            const SizedBox(height: 20),

            Text(
              l10n.communityCreateHashtagsLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hashtagsController,
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDecoration(l10n.communityCreateHashtagsHint),
            ),

            const SizedBox(height: 24),

            Text(
              l10n.communityCreatePrivacyLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            _buildPrivacyPicker(l10n, accentColor),

            const SizedBox(height: 20),

            Text(
              l10n.communityCreateRulesLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _rulesController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDecoration(l10n.communityCreateRulesHint),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
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
                        l10n.communityCreateSubmitButton,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverAndIconPicker(Color accentColor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _pickImage(isCover: true),
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: _coverFile == null
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2A1B4D), Color(0xFF120F1F)],
                    )
                  : null,
              image: _coverFile != null
                  ? DecorationImage(
                      image: FileImage(_coverFile!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _coverFile == null
                ? const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white38,
                      size: 32,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          left: 16,
          bottom: -30,
          child: GestureDetector(
            onTap: () => _pickImage(isCover: false),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: accentColor.withOpacity(.2),
                backgroundImage: _iconFile != null
                    ? FileImage(_iconFile!)
                    : null,
                child: _iconFile == null
                    ? Icon(Icons.groups_rounded, color: accentColor)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CategoryGroup>(
          value: _selectedGroup,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          style: const TextStyle(color: Colors.white),
          items: kZentryCategoryGroups
              .map(
                (group) => DropdownMenuItem(
                  value: group,
                  child: Text('${group.emoji}  ${group.name}'),
                ),
              )
              .toList(),
          onChanged: (group) {
            if (group == null) return;
            setState(() {
              _selectedGroup = group;
              _selectedSubcategory = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubcategoryDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedSubcategory,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          style: const TextStyle(color: Colors.white),
          hint: Text(
            l10n.communityCreateSubcategoryNone,
            style: const TextStyle(color: Colors.white54),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(l10n.communityCreateSubcategoryNone),
            ),
            ..._selectedGroup.subcategories.map(
              (sub) => DropdownMenuItem<String?>(value: sub, child: Text(sub)),
            ),
          ],
          onChanged: (sub) => setState(() => _selectedSubcategory = sub),
        ),
      ),
    );
  }

  Widget _buildPrivacyPicker(AppLocalizations l10n, Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: _privacyCard(
            selected: _privacy == CommunityPrivacy.public,
            icon: Icons.public,
            title: l10n.communityCreatePrivacyPublic,
            subtitle: l10n.communityCreatePrivacyPublicDesc,
            accentColor: accentColor,
            onTap: () => setState(() => _privacy = CommunityPrivacy.public),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _privacyCard(
            selected: _privacy == CommunityPrivacy.private,
            icon: Icons.lock_outline,
            title: l10n.communityCreatePrivacyPrivate,
            subtitle: l10n.communityCreatePrivacyPrivateDesc,
            accentColor: accentColor,
            onTap: () => setState(() => _privacy = CommunityPrivacy.private),
          ),
        ),
      ],
    );
  }

  Widget _privacyCard({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withOpacity(.16)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? accentColor : Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? accentColor : Colors.white70),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? accentColor : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorStyle: TextStyle(color: Colors.red.shade200),
    );
  }
}
