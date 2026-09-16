import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/community.dart';
import 'package:Zentry/core/models/creative_challenge.dart';
import 'package:Zentry/core/models/zentry_category.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/providers/creative_challenge_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class CreateCreativeChallengeScreen extends StatefulWidget {
  final String? communityId;

  const CreateCreativeChallengeScreen({super.key, this.communityId});

  @override
  State<CreateCreativeChallengeScreen> createState() =>
      _CreateCreativeChallengeScreenState();
}

class _CreateCreativeChallengeScreenState
    extends State<CreateCreativeChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();

  CategoryGroup _selectedGroup = kZentryCategoryGroups.first;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  Community? _selectedCommunity;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.communityId != null) {
      final communities = context.read<CommunityController>().communities;
      final match = communities.where((c) => c.id == widget.communityId);
      if (match.isNotEmpty) _selectedCommunity = match.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_endDate.isAfter(_startDate)) return;

    setState(() => _saving = true);

    final user = context.read<AuthController>().currentUser;
    if (user == null) {
      setState(() => _saving = false);
      return;
    }

    await context.read<CreativeChallengeController>().createChallenge(
      title: _titleController.text,
      description: _descriptionController.text,
      categoryName: _selectedGroup.name,
      source: _selectedCommunity != null
          ? ChallengeSource.community
          : ChallengeSource.user,
      creatorId: user.id,
      creatorName: user.displayName,
      startDate: _startDate,
      endDate: _endDate,
      rules: _rulesController.text,
      communityId: _selectedCommunity?.id,
      communityName: _selectedCommunity?.name,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final user = context.watch<AuthController>().currentUser;
    final myCommunities = user != null
        ? context
              .watch<CommunityController>()
              .myCommunities(user.id)
              .where(
                (c) =>
                    context.read<CommunityController>().roleOf(c.id, user.id) !=
                    null,
              )
              .toList()
        : <Community>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.challengeCreateTitle)),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(l10n.challengeTitleHint),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? l10n.challengeTitleRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(l10n.challengeDescriptionHint),
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
                    if (g != null) setState(() => _selectedGroup = g);
                  },
                ),
              ),
            ),
            if (myCommunities.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Community?>(
                    value: _selectedCommunity,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).cardColor,
                    style: const TextStyle(color: Colors.white),
                    hint: Text(
                      l10n.challengePersonalOption,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    items: [
                      DropdownMenuItem<Community?>(
                        value: null,
                        child: Text(l10n.challengePersonalOption),
                      ),
                      ...myCommunities.map(
                        (c) => DropdownMenuItem<Community?>(
                          value: c,
                          child: Text(c.name),
                        ),
                      ),
                    ],
                    onChanged: (c) => setState(() => _selectedCommunity = c),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    label: l10n.challengeStartDateLabel,
                    date: _startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateField(
                    label: l10n.challengeEndDateLabel,
                    date: _endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rulesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration(l10n.challengeRulesHint),
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
                        l10n.challengeCreateButton,
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
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
