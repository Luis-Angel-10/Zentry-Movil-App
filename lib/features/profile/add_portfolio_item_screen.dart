import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/portfolio_item.dart';
import 'package:Zentry/core/models/zentry_category.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/portfolio_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class AddPortfolioItemScreen extends StatefulWidget {
  const AddPortfolioItemScreen({super.key});

  @override
  State<AddPortfolioItemScreen> createState() => _AddPortfolioItemScreenState();
}

class _AddPortfolioItemScreenState extends State<AddPortfolioItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _toolsController = TextEditingController();
  final _linkController = TextEditingController();

  File? _imageFile;
  CategoryGroup _selectedGroup = kZentryCategoryGroups.first;
  String? _selectedSubcategory;
  PortfolioStatus _status = PortfolioStatus.completed;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _toolsController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final user = context.read<AuthController>().currentUser;
    if (user == null) {
      setState(() => _saving = false);
      return;
    }

    final tools = _toolsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    await context.read<PortfolioController>().addItem(
      userId: user.id,
      title: _titleController.text,
      description: _descriptionController.text,
      categoryName: _selectedGroup.name,
      subcategoryName: _selectedSubcategory,
      status: _status,
      imagePath: _imageFile?.path,
      tools: tools,
      externalLink: _linkController.text,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.portfolioAddTitle)),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).cardColor,
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? const Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.white38,
                          size: 32,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(l10n.portfolioTitleHint),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? l10n.portfolioTitleRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(l10n.portfolioDescriptionHint),
            ),
            const SizedBox(height: 16),
            Container(
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
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text('${g.emoji}  ${g.name}'),
                        ),
                      )
                      .toList(),
                  onChanged: (g) {
                    if (g == null) return;
                    setState(() {
                      _selectedGroup = g;
                      _selectedSubcategory = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _toolsController,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(l10n.portfolioToolsHint),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _linkController,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(l10n.portfolioLinkHint),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: PortfolioStatus.values.map((status) {
                final selected = _status == status;
                return ChoiceChip(
                  label: Text(_statusLabel(l10n, status)),
                  selected: selected,
                  onSelected: (_) => setState(() => _status = status),
                  backgroundColor: Theme.of(context).cardColor,
                  selectedColor: accentColor,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade400,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
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
                        l10n.portfolioAddButton,
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, PortfolioStatus status) {
    switch (status) {
      case PortfolioStatus.concept:
        return l10n.portfolioStatusConcept;
      case PortfolioStatus.inProgress:
        return l10n.portfolioStatusInProgress;
      case PortfolioStatus.completed:
        return l10n.portfolioStatusCompleted;
    }
  }

  InputDecoration _decoration(String hint) {
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
    );
  }
}
